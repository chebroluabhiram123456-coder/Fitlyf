import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fitlyf/models/workout_model.dart';
import 'package:fitlyf/models/exercise_model.dart';
import 'package:provider/provider.dart';
import 'package:fitlyf/providers/workout_provider.dart';
import 'package:fitlyf/widgets/frosted_glass_card.dart';
import 'package:fitlyf/screens/exercise_detail_screen.dart';

class WorkoutDetailScreen extends StatefulWidget {
  final Workout workout;
  const WorkoutDetailScreen({required this.workout, Key? key}) : super(key: key);

  @override
  _WorkoutDetailScreenState createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen> {
  Timer? _timer;
  int _seconds = 0;
  bool _isTimerRunning = false;
  late List<Exercise> _orderedExercises;

  @override
  void initState() {
    super.initState();
    _orderedExercises = List.from(widget.workout.exercises);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    setState(() { _isTimerRunning = true; });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() { _seconds++; });
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() { _isTimerRunning = false; });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() { _seconds = 0; _isTimerRunning = false; });
  }

  String _formatTime() {
    int minutes = _seconds ~/ 60;
    int seconds = _seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
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
            _buildTimerCard(),
            Expanded(
              child: Consumer<WorkoutProvider>(
                builder: (context, workoutProvider, child) {
                  return ReorderableListView.builder(
                    padding: const EdgeInsets.all(20.0),
                    itemCount: _orderedExercises.length,
                    itemBuilder: (ctx, index) {
                      final exercise = _orderedExercises[index];
                      // Find the latest state of this exercise from the provider
                      final latestExerciseState = workoutProvider.allExercises.firstWhere((e) => e.id == exercise.id, orElse: () => exercise);
                      
                      return Padding(
                        key: ValueKey(exercise.id),
                        padding: const EdgeInsets.only(bottom: 15.0),
                        child: FrostedGlassCard(
                          padding: const EdgeInsets.all(5),
                          child: ListTile(
                            leading: Checkbox(
                              value: latestExerciseState.isCompleted,
                              activeColor: Colors.white,
                              checkColor: const Color(0xFF2D1458),
                              onChanged: (bool? value) {
                                if (value != null) {
                                  workoutProvider.toggleExerciseCompletion(exercise.id, value);
                                }
                              },
                            ),
                            title: Text(exercise.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(
                                '${exercise.sets} sets x ${exercise.reps} reps - ${exercise.targetMuscle}',
                                style: const TextStyle(color: Colors.white70)),
                            trailing: ReorderableDragStartListener(
                              index: index,
                              child: const Icon(Icons.drag_handle, color: Colors.white70),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ExerciseDetailScreen(exercise: exercise),
                                ),
                              );
                            },
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
                  );
                },
              ),
            ),
            _buildFinishWorkoutButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildFinishWorkoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            final provider = Provider.of<WorkoutProvider>(context, listen: false);
            
            // THE FIX: Call the new function to tick all checkboxes.
            provider.markAllExercisesAsComplete(_orderedExercises);

            // This marks the day as completed for the calendar.
            provider.markWorkoutAsComplete(provider.selectedDate);

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Workout Complete! Great job!"), backgroundColor: Colors.green),
            );
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF2D1458),
            padding: const EdgeInsets.symmetric(vertical: 15),
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          child: const Text('Finish Workout'),
        ),
      ),
    );
  }

  Widget _buildTimerCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 20.0),
      child: FrostedGlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _formatTime(),
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 2),
            ),
            Row(children: [
                IconButton(icon: Icon(_isTimerRunning ? Icons.pause_circle_outline : Icons.play_circle_outline), iconSize: 30, onPressed: _isTimerRunning ? _pauseTimer : _startTimer),
                IconButton(icon: const Icon(Icons.replay), iconSize: 30, onPressed: _resetTimer),
            ]),
          ],
        ),
      ),
    );
  }
}
