  import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fitlyf/models/workout_model.dart';
import 'package:fitlyf/models/exercise_model.dart';
import 'package:provider/provider.dart';
import 'package:fitlyf/providers/workout_provider.dart';
import 'package:fitlyf/widgets/frosted_glass_card.dart';
import 'package:fitlyf/screens/exercise_detail_screen.dart';
import 'package:fitlyf/helpers/fade_route.dart';
import 'package:fitlyf/screens/live_workout_screen.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<WorkoutProvider>(context, listen: false).startWorkoutSession();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
  
  // --- Timer functions are unchanged ---
  void _startTimer() { setState(() { _isTimerRunning = true; }); _timer = Timer.periodic(const Duration(seconds: 1), (timer) { setState(() { _seconds++; }); }); }
  void _pauseTimer() { _timer?.cancel(); setState(() { _isTimerRunning = false; }); }
  void _resetTimer() { _timer?.cancel(); setState(() { _seconds = 0; _isTimerRunning = false; }); }
  String _formatTime() { int minutes = _seconds ~/ 60; int seconds = _seconds % 60; return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}'; }

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
            
            // THE FIX 1: Add the new, prominent "Start Workout" button card.
            _buildStartWorkoutCard(context),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Divider(color: Colors.white24),
            ),
            
            Expanded(
              child: Consumer<WorkoutProvider>(
                builder: (context, workoutProvider, child) {
                  return ReorderableListView.builder(
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
                              onChanged: (bool? value) {
                                if (value != null) {
                                  workoutProvider.toggleInProgressExerciseCompletion(exercise.id, value);
                                  if (workoutProvider.areAllExercisesComplete(_orderedExercises)) {
                                    _finishWorkout(context, workoutProvider);
                                  }
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
                              Navigator.push(context, FadePageRoute(child: ExerciseDetailScreen(exercise: exercise)));
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
            // THE FIX 2: Rename the old button to clarify its function.
            _buildQuickLogButton(context),
          ],
        ),
      ),
    );
  }

  // THE FIX 3: This is the new widget for the "Start Workout" button.
  Widget _buildStartWorkoutCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: GestureDetector(
        onTap: () {
          final reorderedWorkout = Workout(id: widget.workout.id, name: widget.workout.name, exercises: _orderedExercises);
          Navigator.push(context, FadePageRoute(child: LiveWorkoutScreen(workout: reorderedWorkout)));
        },
        child: FrostedGlassCard(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 28),
              const SizedBox(width: 10),
              Text("Start Live Workout", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  // THE FIX 4: This button is now clearly for "Quick Logging".
  Widget _buildQuickLogButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            final provider = Provider.of<WorkoutProvider>(context, listen: false);
            provider.markAllExercisesAsComplete(_orderedExercises);
            _finishWorkout(context, provider);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF2D1458),
            padding: const EdgeInsets.symmetric(vertical: 15),
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          child: const Text('Quick Log & Finish'),
        ),
      ),
    );
  }

  void _finishWorkout(BuildContext context, WorkoutProvider provider) {
    final completedWorkout = Workout(id: widget.workout.id, name: widget.workout.name, exercises: _orderedExercises);
    provider.logWorkout(provider.selectedDate, completedWorkout);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Workout Complete! Great job!"), backgroundColor: Colors.green),
    );
    Navigator.of(context).pop();
  }

  Widget _buildTimerCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 20.0),
      child: FrostedGlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_formatTime(), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 2)),
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
