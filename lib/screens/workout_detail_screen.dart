import 'package:flutter/material.dart';
import 'package:fitlyf/models/workout_model.dart';
import 'package:fitlyf/models/exercise_model.dart';
import 'package:provider/provider.dart';
import 'package:fitlyf/providers/workout_provider.dart';
import 'package:fitlyf/widgets/frosted_glass_card.dart';
import 'package:fitlyf/screens/exercise_detail_screen.dart';
import 'package:fitlyf/helpers/fade_route.dart';
import 'package:fitlyf/screens/live_workout_screen.dart';
import 'package:fitlyf/widgets/modern_progress_bar.dart';

class WorkoutDetailScreen extends StatefulWidget {
  final Workout workout;
  const WorkoutDetailScreen({required this.workout, Key? key}) : super(key: key);

  @override
  _WorkoutDetailScreenState createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen> {
  late List<Exercise> _orderedExercises;

  @override
  void initState() {
    super.initState();
    _orderedExercises = List.from(widget.workout.exercises);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<WorkoutProvider>(context, listen: false).startWorkoutSession();
    });
  }
  
  @override
  void dispose() {
    super.dispose();
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
          title: Text(widget.workout.name),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Column(
          children: [
            Expanded(
              child: Consumer<WorkoutProvider>(
                builder: (context, workoutProvider, child) {
                  final isWorkoutComplete = workoutProvider.workoutLog.containsKey(DateUtils.dateOnly(workoutProvider.selectedDate));
                  final exercisesInThisWorkout = _orderedExercises.map((e) => e.id).toSet();
                  final completedCount = workoutProvider.inProgressExerciseIds.where((id) => exercisesInThisWorkout.contains(id)).length;
                  final totalCount = _orderedExercises.length;
                  final progress = totalCount > 0 ? completedCount / totalCount : 0.0;
                  
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        child: ModernProgressBar(progress: progress),
                      ),
                      Expanded(
                        child: ReorderableListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          itemCount: _orderedExercises.length,
                          itemBuilder: (ctx, index) {
                            final exercise = _orderedExercises[index];
                            return Padding(
                              key: ValueKey(exercise.id),
                              padding: const EdgeInsets.only(bottom: 15.0),
                              child: FrostedGlassCard(
                                padding: const EdgeInsets.all(5),
                                child: ListTile(
                                  leading: Checkbox(
                                    value: workoutProvider.isExerciseInProgressCompleted(exercise.id),
                                    activeColor: Colors.white,
                                    checkColor: const Color(0xFF2D1458),
                                    onChanged: isWorkoutComplete ? null : (bool? value) {
                                      if (value != null) {
                                        workoutProvider.toggleInProgressExerciseCompletion(exercise.id, value);
                                        if (workoutProvider.areAllExercisesComplete(_orderedExercises)) {
                                          _finishWorkout(context, workoutProvider);
                                        }
                                      }
                                    },
                                  ),
                                  title: Text(exercise.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Text('${exercise.sets} sets x ${exercise.reps} reps - ${exercise.targetMuscle}', style: const TextStyle(color: Colors.white70)),
                                  trailing: ReorderableDragStartListener(index: index, child: const Icon(Icons.drag_handle, color: Colors.white70)),
                                  onTap: () { Navigator.push(context, FadePageRoute(child: ExerciseDetailScreen(exercise: exercise))); },
                                ),
                              ),
                            );
                          },
                          onReorder: (int oldIndex, int newIndex) {
                            setState(() {
                               if (newIndex > oldIndex) newIndex -= 1;
                               final item = _orderedExercises.removeAt(oldIndex);
                               _orderedExercises.insert(newIndex, item);
                            });
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  void _finishWorkout(BuildContext context, WorkoutProvider provider) {
    final completedWorkout = Workout(id: widget.workout.id, name: widget.workout.name, exercises: _orderedExercises);
    provider.logWorkout(provider.selectedDate, completedWorkout);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Workout Complete! Great job!"), backgroundColor: Colors.green));
    Navigator.of(context).pop();
  }
  
  Widget _buildActionButtons(BuildContext context) {
    final provider = Provider.of<WorkoutProvider>(context);
    final isWorkoutComplete = provider.workoutLog.containsKey(DateUtils.dateOnly(provider.selectedDate));
    if (isWorkoutComplete) {
      return const Padding(
        padding: EdgeInsets.fromLTRB(20, 10, 20, 30),
        child: Text("Workout already logged for this day.", textAlign: TextAlign.center, style: TextStyle(color: Colors.greenAccent, fontSize: 16)),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                final reorderedWorkout = Workout(id: widget.workout.id, name: widget.workout.name, exercises: _orderedExercises);
                Navigator.push(context, FadePageRoute(child: LiveWorkoutScreen(workout: reorderedWorkout)));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white, foregroundColor: const Color(0xFF2D1458),
                padding: const EdgeInsets.symmetric(vertical: 15),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text('Start Live'),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                provider.markAllExercisesAsComplete(_orderedExercises);
                _finishWorkout(context, provider);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.2), foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30), side: const BorderSide(color: Colors.white54)),
              ),
              child: const Text('Quick Log'),
            ),
          ),
        ],
      ),
    );
  }
}
