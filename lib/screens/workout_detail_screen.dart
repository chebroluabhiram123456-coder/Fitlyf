// lib/screens/workout_detail_screen.dart
import 'package:flutter/material.dart';
import '../models/workout_session.dart';

// FIX: The class now has a constructor to receive workout data.
class WorkoutDetailScreen extends StatelessWidget {
  final WorkoutSession workout;

  const WorkoutDetailScreen({Key? key, required this.workout}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(workout.name),
      ),
      body: ListView.builder(
        itemCount: workout.exercises.length,
        itemBuilder: (context, index) {
          final exercise = workout.exercises[index];
          return ListTile(
            title: Text(exercise.name),
            // Add other details or functionality here
          );
        },
      ),
    );
  }
}
