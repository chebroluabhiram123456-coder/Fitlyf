import 'package:flutter/material.dart';
import 'package:fitlyf/models/workout_session.dart';
import 'package:fitlyf/models/exercise_model.dart';

class WorkoutDetailScreen extends StatelessWidget {
  final WorkoutSession workout;
  const WorkoutDetailScreen({super.key, required this.workout});

  @override
  Widget build(BuildContext context) {
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
                '${workout.exercises.length} Exercises',
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
                final exercise = workout.exercises[index];
                return _buildExerciseListItem(exercise);
              },
              childCount: workout.exercises.length,
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomButtons(),
    );
  }

  Widget _buildExerciseListItem(Exercise exercise) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.name,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${exercise.sets} sets x ${exercise.reps} reps x ${exercise.weight} kg',
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
          ),
          const Icon(Icons.drag_handle, color: Colors.white54)
        ],
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
