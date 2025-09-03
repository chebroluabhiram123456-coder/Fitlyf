import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fitflow/providers/workout_provider.dart';
import 'package:fitflow/widgets/gradient_background.dart';
import 'package:fitflow/screens/add_exercise_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Using a Consumer to listen for changes in WorkoutProvider
    return Consumer<WorkoutProvider>(
      builder: (context, provider, child) {
        final todayWorkout = provider.getTodaysWorkout();
        final theme = Theme.of(context).textTheme;

        return GradientBackground(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Text(
                'Today\'s Plan: ${todayWorkout.muscleTarget}',
                style: theme.titleLarge,
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.white),
                  onPressed: () {
                    // Logic to edit muscle target
                     _showEditTargetDialog(context, provider);
                  },
                )
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('EEEE, MMMM d').format(DateTime.now()),
                    style: theme.headlineSmall?.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: todayWorkout.exercises.isEmpty
                      ? Center(
                          child: Text(
                            "It's a rest day! 🎉",
                            style: theme.bodyLarge?.copyWith(color: Colors.white),
                          ),
                        )
                      : ListView.builder(
                      itemCount: todayWorkout.exercises.length,
                      itemBuilder: (context, index) {
                        final exercise = todayWorkout.exercises[index];
                        return Card(
                          color: Colors.black.withOpacity(0.3),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            title: Text(exercise.name, style: theme.bodyLarge?.copyWith(color: Colors.white)),
                            subtitle: Text(
                              '${exercise.sets} sets x ${exercise.reps} reps @ ${exercise.weight} kg',
                              style: theme.bodyMedium?.copyWith(color: Colors.white70),
                            ),
                            trailing: Checkbox(
                              value: exercise.isCompleted,
                              onChanged: (bool? value) {
                                provider.toggleExerciseCompletion(exercise.id);
                              },
                              activeColor: Colors.cyanAccent,
                              checkColor: Colors.black,
                              side: const BorderSide(color: Colors.white),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                // Navigate to add custom exercise screen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddExerciseScreen()),
                );
              },
              backgroundColor: Colors.cyanAccent,
              child: const Icon(Icons.add, color: Colors.black),
            ),
          ),
        );
      },
    );
  }

  void _showEditTargetDialog(BuildContext context, WorkoutProvider provider) {
    final TextEditingController controller = TextEditingController();
    controller.text = provider.getTodaysWorkout().muscleTarget;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0d47a1),
          title: const Text('Update Muscle Target', style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: "e.g., Legs & Shoulders",
              hintStyle: TextStyle(color: Colors.white54)
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  provider.updateTodaysMuscleTarget(controller.text);
                  Navigator.pop(context);
                }
              },
              child: const Text('Save', style: TextStyle(color: Colors.cyanAccent)),
            ),
          ],
        );
      },
    );
  }
}
