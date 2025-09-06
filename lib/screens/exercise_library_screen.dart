import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitlyf/providers/workout_provider.dart';
import 'package:fitlyf/widgets/frosted_glass_card.dart';
import 'package:fitlyf/models/exercise_model.dart';
import 'package:fitlyf/screens/add_exercise_screen.dart';
import 'package:fitlyf/helpers/fade_route.dart'; // <-- IMPORT FADE ROUTE
import 'package:fitlyf/widgets/animated_list_item.dart'; // <-- IMPORT LIST ANIMATION WIDGET

class ExerciseLibraryScreen extends StatelessWidget {
  const ExerciseLibraryScreen({Key? key}) : super(key: key);

  void _showDeleteConfirmation(BuildContext context, WorkoutProvider provider, Exercise exercise) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog( /* ... unchanged ... */
        backgroundColor: const Color(0xFF3E246E),
        title: const Text('Confirm Deletion', style: TextStyle(color: Colors.white)),
        content: Text('Are you sure you want to delete "${exercise.name}"? This action cannot be undone.', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
            onPressed: () {
              provider.deleteExercise(exercise.id);
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${exercise.name} deleted.'), backgroundColor: Colors.red),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          title: const Text('Exercise Library'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Consumer<WorkoutProvider>(
          builder: (context, workoutProvider, child) {
            final groupedExercises = <String, List<Exercise>>{};
            for (var exercise in workoutProvider.allExercises) {
              if (!groupedExercises.containsKey(exercise.targetMuscle)) {
                groupedExercises[exercise.targetMuscle] = [];
              }
              groupedExercises[exercise.targetMuscle]!.add(exercise);
            }
            final muscleGroups = groupedExercises.keys.toList()..sort();

            if (muscleGroups.isEmpty) { /* ... unchanged ... */
              return const Center(
                  child: Text(
                'Your library is empty.\nTap the + button to add an exercise!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: muscleGroups.length,
              itemBuilder: (context, index) {
                final muscle = muscleGroups[index];
                final exercises = groupedExercises[muscle]!;

                // THE FIX 4: Wrap the entire section in our new animation widget
                return AnimatedListItem(
                  index: index,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          muscle,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ...exercises.map((exercise) => Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: FrostedGlassCard(/* ... unchanged ... */
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                            child: Row(
                              children: [
                                const Icon(Icons.fitness_center, color: Colors.white70),
                                const SizedBox(width: 15),
                                Expanded(child: Text(exercise.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))),
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, color: Colors.white70, size: 20),
                                  onPressed: () {
                                    Navigator.push(context, FadePageRoute(child: AddExerciseScreen(exerciseToEdit: exercise)));
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                  onPressed: () {
                                    _showDeleteConfirmation(context, workoutProvider, exercise);
                                  },
                                ),
                              ],
                            ),
                          ),
                        )).toList(),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(context, FadePageRoute(child: const AddExerciseScreen()));
          },
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF2D1458),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
