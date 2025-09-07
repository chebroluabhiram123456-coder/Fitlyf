import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitlyf/models/workout_model.dart';
import 'package:fitlyf/models/exercise_model.dart';
import 'package:fitlyf/providers/workout_provider.dart';
import 'package:fitlyf/screens/live_workout_screen.dart';

class WorkoutDetailScreen extends StatefulWidget {
  final Workout workout;

  const WorkoutDetailScreen({super.key, required this.workout});

  @override
  State<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen> {
  // We need a local state copy of the exercises to allow reordering
  late List<Exercise> _reorderableExercises;

  @override
  void initState() {
    super.initState();
    // Create a mutable copy of the exercises list from the workout
    _reorderableExercises = List.of(widget.workout.exercises);
  }
  
  // Handles the logic for reordering the list
  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final Exercise item = _reorderableExercises.removeAt(oldIndex);
      _reorderableExercises.insert(newIndex, item);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Using a Consumer to ensure the UI rebuilds when provider data changes
    return Consumer<WorkoutProvider>(
      builder: (context, workoutProvider, child) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: CustomScrollView(
            slivers: [
              _buildSliverAppBar(),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatRow(context, workoutProvider),
                      const SizedBox(height: 30),
                      const Text("Exercises", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
              // This is the new reorderable list of exercises
              SliverReorderableList(
                itemBuilder: (context, index) {
                  final exercise = _reorderableExercises[index];
                  final isCompleted = workoutProvider.inProgressExerciseIds.contains(exercise.id);

                  return ReorderableDelayedDragStartListener(
                    key: ValueKey(exercise.id), // Keys are crucial for reordering
                    index: index,
                    child: CheckboxListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
                      title: Text(exercise.name, style: const TextStyle(color: Colors.white)),
                      subtitle: Text(
                        '${exercise.targetMuscle} • ${exercise.sets} sets, ${exercise.reps} reps',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      value: isCompleted,
                      onChanged: (bool? value) {
                        workoutProvider.toggleExerciseStatus(exercise.id);
                      },
                      activeColor: Colors.greenAccent,
                      checkColor: Colors.black,
                      secondary: const Icon(Icons.drag_handle, color: Colors.white30),
                    ),
                  );
                },
                itemCount: _reorderableExercises.length,
                onReorder: _onReorder,
              ),
              // This ensures the buttons are always at the bottom
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: _buildActionButtons(context, workoutProvider),
                )
              ),
            ],
          ),
        );
      }
    );
  }

  SliverAppBar _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 250.0,
      backgroundColor: Colors.transparent,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(widget.workout.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        background: Container(
          color: Colors.grey[900],
          child: const Icon(Icons.fitness_center, size: 100, color: Colors.white24),
        ),
      ),
    );
  }

  Widget _buildStatRow(BuildContext context, WorkoutProvider workoutProvider) {
    final exercisesInThisWorkout = widget.workout.exercises.map((e) => e.id).toSet();
    final completedCount = workoutProvider.inProgressExerciseIds
        .where((id) => exercisesInThisWorkout.contains(id))
        .length;
    final totalExercises = widget.workout.exercises.length;
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
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: progress),
            duration: const Duration(milliseconds: 500),
            builder: (context, value, child) => CircularProgressIndicator(
              value: value,
              strokeWidth: 6,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.greenAccent),
            ),
          ),
        )
      ],
    );
  }
  
  Widget _buildActionButtons(BuildContext context, WorkoutProvider workoutProvider) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Live workout button uses the reordered list
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.greenAccent,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          onPressed: () {
            // Create a new workout object with the reordered exercises to pass to the next screen
            final reorderedWorkout = widget.workout.copyWith(exercises: _reorderableExercises);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LiveWorkoutScreen(workout: reorderedWorkout)),
            );
          },
          child: const Text('Start Live Workout', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 15),
        // Quick Log button
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[800],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          onPressed: () {
            // Call the new provider method
            workoutProvider.quickLogWorkout(widget.workout);
            // Show a confirmation message and navigate back
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Workout Logged! Great job!'), backgroundColor: Colors.green),
            );
            Navigator.pop(context);
          },
          child: const Text('Quick Log', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}

// NOTE: You will need to add a `copyWith` method to your Workout model for the reordering to work seamlessly.
// Add this to your `lib/models/workout_model.dart` file:
/*
  Workout copyWith({
    String? id,
    String? name,
    List<Exercise>? exercises,
    // ... any other properties
  }) {
    return Workout(
      id: id ?? this.id,
      name: name ?? this.name,
      exercises: exercises ?? this.exercises,
      // ... any other properties
    );
  }
*/
