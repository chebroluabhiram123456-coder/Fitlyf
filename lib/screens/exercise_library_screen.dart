import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitlyf/providers/workout_provider.dart';
import 'package:fitlyf/widgets/frosted_glass_card.dart';

class ExerciseLibraryScreen extends StatelessWidget {
  const ExerciseLibraryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutProvider>(
      builder: (context, workoutProvider, child) {
        final allExercises = workoutProvider.allExercises;

        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text('Exercise Library'),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: allExercises.isEmpty
              ? const Center(
                  child: Text(
                    'Your exercise library is empty.\nCreate a new exercise to get started!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: allExercises.length,
                  itemBuilder: (context, index) {
                    final exercise = allExercises[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 15.0),
                      child: FrostedGlassCard(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        child: Row(
                          children: [
                            const Icon(Icons.fitness_center, color: Colors.white70),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    exercise.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    exercise.targetMuscle,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // We can add edit/delete buttons here later
                          ],
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}
