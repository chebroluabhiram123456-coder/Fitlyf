import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fitlyf/models/workout_model.dart';
import 'package:provider/provider.dart';
import 'package:fitlyf/providers/workout_provider.dart';
import 'package:fitlyf/widgets/frosted_glass_card.dart';
import 'package:fitlyf/screens/exercise_detail_screen.dart'; // Import the new screen

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

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _isTimerRunning = true;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
      });
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isTimerRunning = false;
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _seconds = 0;
      _isTimerRunning = false;
    });
  }

  String _formatTime() {
    int minutes = _seconds ~/ 60;
    int seconds = _seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Inherit the main gradient
      appBar: AppBar(
        title: Text(widget.workout.name),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // THE FIX: The new timer widget
          _buildTimerCard(),
          
          // THE FIX: The list of exercises now uses the Consumer to update in real-time
          Expanded(
            child: Consumer<WorkoutProvider>(
              builder: (context, workoutProvider, child) {
                // We need to get the latest state of the exercises from the provider
                final currentWorkout = workoutProvider.allExercises.where((ex) => widget.workout.exercises.any((wEx) => wEx.id == ex.id)).toList();
                
                return ListView.builder(
                  padding: const EdgeInsets.all(20.0),
                  itemCount: currentWorkout.length,
                  itemBuilder: (ctx, index) {
                    final exercise = currentWorkout[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 15.0),
                      // THE FIX: Using the stylish FrostedGlassCard
                      child: FrostedGlassCard(
                        padding: const EdgeInsets.all(5),
                        child: ListTile(
                          // THE FIX: The checkbox now works and updates stats
                          leading: Checkbox(
                            value: exercise.isCompleted,
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
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            // THE FIX: Tapping now navigates to the new detail screen
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
                );
              },
            ),
          ),
          
          // THE FIX: The new "Finish Workout" button
          _buildFinishWorkoutButton(context),
        ],
      ),
    );
  }

  Widget _buildTimerCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: FrostedGlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _formatTime(),
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 2),
            ),
            Row(
              children: [
                IconButton(
                  icon: Icon(_isTimerRunning ? Icons.pause_circle_outline : Icons.play_circle_outline),
                  iconSize: 30,
                  onPressed: _isTimerRunning ? _pauseTimer : _startTimer,
                ),
                IconButton(
                  icon: const Icon(Icons.replay),
                  iconSize: 30,
                  onPressed: _resetTimer,
                ),
              ],
            ),
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
            // TODO: Add logic to save the completed workout session to the log
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
}
