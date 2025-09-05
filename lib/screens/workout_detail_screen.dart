import 'package:flutter/material.dart';
import 'package:fitlyf/models/workout_model.dart'; // THE FIX: Changed the import
import 'package:provider/provider.dart';
import 'package:fitlyf/providers/workout_provider.dart';

// THE FIX: The screen now accepts a 'Workout' object
class WorkoutDetailScreen extends StatelessWidget {
  final Workout workout;

  WorkoutDetailScreen({required this.workout});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(workout.name),
      ),
      body: ListView.builder(
        itemCount: workout.exercises.length,
        itemBuilder: (ctx, index) {
          final exercise = workout.exercises[index];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: Checkbox(
                value: exercise.isCompleted,
                onChanged: (bool? value) {
                  if (value != null) {
                    Provider.of<WorkoutProvider>(context, listen: false)
                        .toggleExerciseCompletion(exercise.id, value);
                  }
                },
              ),
              title: Text(exercise.name),
              subtitle: Text(
                  '${exercise.sets} sets x ${exercise.reps} reps - ${exercise.targetMuscle}'),
              trailing: Icon(Icons.fitness_center),
            ),
          );
        },
      ),
    );
  }
}
