import 'package:flutter/material.dart';
import 'package:fitlyf/models/workout_model.dart';
import 'package:fitlyf/providers/workout_provider.dart';
import 'package:provider/provider.dart';
import 'package:fitlyf/helpers/fade_route.dart';
import 'package:fitlyf/screens/live_workout_screen.dart';

class WorkoutDetailScreen extends StatelessWidget {
  final Workout workout;
  const WorkoutDetailScreen({required this.workout, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // The UI of this screen can be simplified now that "Start Workout" is the main action
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4A148C), Color(0xFF2D1458), Color(0xFF1A0E38)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(workout.name),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(20.0),
                itemCount: workout.exercises.length,
                itemBuilder: (ctx, index) {
                  final exercise = workout.exercises[index];
                  return Card(
                    color: Colors.white.withOpacity(0.1),
                    margin: const EdgeInsets.only(bottom: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: ListTile(
                      leading: const Icon(Icons.fitness_center, color: Colors.white70),
                      title: Text(exercise.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${exercise.sets} sets x ${exercise.reps} reps', style: const TextStyle(color: Colors.white70)),
                    ),
                  );
                },
              ),
            ),
            _buildStartWorkoutButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStartWorkoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            // Navigate to the new Live Workout Screen
            Navigator.push(
              context,
              FadePageRoute(child: LiveWorkoutScreen(workout: workout)),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF2D1458),
            padding: const EdgeInsets.symmetric(vertical: 15),
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          child: const Text('Start Workout'),
        ),
      ),
    );
  }
}
