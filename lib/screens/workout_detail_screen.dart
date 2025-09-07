import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitlyf/models/workout_model.dart';
import 'package:fitlyf/providers/workout_provider.dart';
import 'package:fitlyf/screens/live_workout_screen.dart';

class WorkoutDetailScreen extends StatelessWidget {
  final Workout workout;

  const WorkoutDetailScreen({super.key, required this.workout});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250.0,
            backgroundColor: Colors.transparent,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(workout.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              background: Container(
                color: Colors.grey[900],
                child: const Icon(Icons.fitness_center, size: 100, color: Colors.white24),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatRow(context),
                  const SizedBox(height: 30),
                  const Text("Exercises", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final exercise = workout.exercises[index];
                return ListTile(
                  leading: const Icon(Icons.circle, size: 12, color: Colors.greenAccent),
                  title: Text(exercise.name, style: const TextStyle(color: Colors.white, fontSize: 16)),
                  // --- SUBTITLE NOW INCLUDES 'targetMuscle' ---
                  subtitle: Text(
                    '${exercise.targetMuscle} • ${exercise.sets} sets, ${exercise.reps} reps',
                    style: const TextStyle(color: Colors.white70)
                  ),
                );
              },
              childCount: workout.exercises.length,
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: _buildActionButtons(context),
            )
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(BuildContext context) {
    final workoutProvider = Provider.of<WorkoutProvider>(context, listen: false);
    final exercisesInThisWorkout = workout.exercises.map((e) => e.id).toSet();
    final completedCount = workoutProvider.inProgressExerciseIds
        .where((id) => exercisesInThisWorkout.contains(id))
        .length;
    final totalExercises = workout.exercises.length;
    final progress = totalExercises > 0 ? completedCount / totalExercises : 0.0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("PROGRESS", style: TextStyle(color: Colors.white70, letterSpacing: 1.5)),
            const SizedBox(height: 5),
            Text("$completedCount / $totalExercises", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        SizedBox(
          width: 80,
          height: 80,
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: 6,
            backgroundColor: Colors.white.withOpacity(0.2),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.greenAccent),
          ),
        )
      ],
    );
  }
  
  Widget _buildActionButtons(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LiveWorkoutScreen(workout: workout),
                    ),
                  );
                },
                child: const Text('Start Workout', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
        ],
    );
  }
}
