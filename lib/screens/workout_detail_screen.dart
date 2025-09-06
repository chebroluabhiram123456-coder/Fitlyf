import 'package:flutter/material.dart';
import 'package:fitlyf/models/workout_model.dart';
import 'package:provider/provider.dart';
import 'package:fitlyf/providers/workout_provider.dart';

class WorkoutDetailScreen extends StatelessWidget {
  final Workout workout;

  const WorkoutDetailScreen({required this.workout, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(workout.name),
      ),
      body: Hero(
        tag: 'workout_card',
        child: Material(
          type: MaterialType.transparency,
          child: ListView.builder(
            itemCount: workout.exercises.length,
            itemBuilder: (ctx, index) {
              final exercise = workout.exercises[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                  trailing: const Icon(Icons.fitness_center),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
