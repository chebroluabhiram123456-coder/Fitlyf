// lib/screens/workout_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/workout_provider.dart';

class WorkoutDetailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WorkoutProvider>(context);
    final updatedWorkout = provider.selectedWorkout;

    // THIS IS THE FIX: Handle the case where there is no workout (rest day)
    if (updatedWorkout == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Rest Day'),
          backgroundColor: Colors.grey[900],
        ),
        body: Center(
          child: Text(
            'Enjoy your rest day!',
            style: TextStyle(fontSize: 24, color: Colors.white),
          ),
        ),
      );
    }

    // The rest of the build method now knows updatedWorkout is not null
    return Scaffold(
      appBar: AppBar(
        title: Text(updatedWorkout.name),
        backgroundColor: Colors.grey[900],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${updatedWorkout.exercises.length} Exercises',
              style: TextStyle(fontSize: 18, color: Colors.grey[400]),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: updatedWorkout.exercises.length,
                itemBuilder: (context, index) {
                  final exercise = updatedWorkout.exercises[index];
                  return Card(
                    color: Colors.grey[850],
                    child: CheckboxListTile(
                      title: Text(exercise.name, style: TextStyle(color: Colors.white)),
                      value: exercise.isCompleted,
                      onChanged: (bool? value) {
                        provider.toggleExerciseCompletion(exercise.id);
                      },
                      activeColor: Colors.blueAccent,
                      checkColor: Colors.black,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
