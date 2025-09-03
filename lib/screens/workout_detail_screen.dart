import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitlyf/models/workout_session.dart';
import 'package:fitlyf/models/exercise_model.dart';
import 'package:fitlyf/providers/workout_provider.dart';

class WorkoutDetailScreen extends StatelessWidget {
  final WorkoutSession workout;
  const WorkoutDetailScreen({super.key, required this.workout});

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutProvider>(
      builder: (context, provider, child) {
        final updatedWorkout = provider.selectedWorkout;

        return Scaffold(
          backgroundColor: const Color(0xFF1A0E38),
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 150.0,
                backgroundColor: const Color(0xFF2D1458),
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    '${updatedWorkout.exercises.length} Exercises',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  centerTitle: false,
                  titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                ),
                actions: [
                  IconButton(icon: const Icon(Icons.add), onPressed: () {}),
                ],
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final exercise = updatedWorkout.exercises[index];
                    return _buildExerciseListItem(context, exercise);
                  },
                  childCount: updatedWorkout.exercises.length,
                ),
              ),
            ],
          ),
          bottomNavigationBar: _buildBottomButtons(),
        );
      },
    );
  }

  Widget _buildExerciseListItem(BuildContext context, Exercise exercise) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        tileColor: exercise.isCompleted ? Colors.black.withOpacity(0.3) : Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(
          exercise.name,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            decoration: exercise.isCompleted ? TextDecoration.lineThrough : null,
            color: exercise.isCompleted ? Colors.white54 : Colors.white,
          ),
        ),
        subtitle: Text(
          '${exercise.sets} sets x ${exercise.reps} reps x ${exercise.weight} kg',
          style: TextStyle(
            fontSize: 14,
            color: exercise.isCompleted ? Colors.white38 : Colors.white70,
          ),
        ),
        trailing: Checkbox(
          value: exercise.isCompleted,
          onChanged: (bool? value) {
            Provider.of<WorkoutProvider>(context, listen: false)
                .toggleExerciseCompletion(exercise.id);
          },
          activeColor: Colors.purple.shade200,
          checkColor: Colors.black,
          side: const BorderSide(color: Colors.white70),
        ),
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            child: const Text("Start Workout", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () {},
            child: const Text("Adapt Workout", style: TextStyle(color: Colors.white, fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
