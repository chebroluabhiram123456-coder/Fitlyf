import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitlyf/providers/workout_provider.dart';
import 'package:fitlyf/models/workout_model.dart';
import 'package:fitlyf/models/exercise_model.dart';
import 'package:fitlyf/models/set_log_model.dart';
import 'package:fitlyf/widgets/frosted_glass_card.dart';

class LiveWorkoutScreen extends StatefulWidget {
  final Workout workout;
  const LiveWorkoutScreen({Key? key, required this.workout}) : super(key: key);

  @override
  _LiveWorkoutScreenState createState() => _LiveWorkoutScreenState();
}

class _LiveWorkoutScreenState extends State<LiveWorkoutScreen> {
  late PageController _pageController;
  late List<Exercise> _exercises;
  int _currentExerciseIndex = 0;
  Timer? _restTimer;
  int _restSecondsRemaining = 60;
  bool _isResting = false;

  @override
  void initState() {
    super.initState();
    _exercises = widget.workout.exercises.map((ex) {
      return Exercise( id: ex.id, name: ex.name, targetMuscle: ex.targetMuscle, sets: ex.sets, reps: ex.reps, description: ex.description, imageUrl: ex.imageUrl, videoUrl: ex.videoUrl, setsLogged: [] );
    }).toList();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _restTimer?.cancel();
    super.dispose();
  }
  
  void _startRestTimer() { setState(() { _isResting = true; _restSecondsRemaining = 60; }); _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) { if (_restSecondsRemaining > 0) { setState(() { _restSecondsRemaining--; }); } else { _finishRest(); } }); }
  void _finishRest() { _restTimer?.cancel(); setState(() { _isResting = false; }); }
  
  void _logSet(int exerciseIndex, int setIndex) {
    final exercise = _exercises[exerciseIndex];
    final reps = exercise.reps; 
    final weight = 50.0; // Placeholder
    
    setState(() { exercise.setsLogged.add(SetLog(reps: reps, weight: weight)); });
    Provider.of<WorkoutProvider>(context, listen: false).logSet(exercise.id, reps, weight);
    if(exercise.setsLogged.length < exercise.sets) { _startRestTimer(); }
  }
  
  void _nextExercise() {
    if (_currentExerciseIndex < _exercises.length - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      _finishWorkout();
    }
  }

  void _finishWorkout() {
    final provider = Provider.of<WorkoutProvider>(context, listen: false);
    final completedWorkout = Workout(id: widget.workout.id, name: widget.workout.name, exercises: _exercises);
    provider.logWorkout(provider.selectedDate, completedWorkout);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Workout Complete! Achievement Unlocked: First Workout!"), backgroundColor: Colors.green),
    );
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    // Show the rest timer overlay if resting
    if (_isResting) { return _buildRestTimerOverlay(); }

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
          title: Text('Exercise ${_currentExerciseIndex + 1} of ${_exercises.length}'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: PageView.builder(
          controller: _pageController,
          itemCount: _exercises.length,
          onPageChanged: (index) { setState(() { _currentExerciseIndex = index; }); },
          itemBuilder: (context, index) {
            final exercise = _exercises[index];
            return _buildExercisePage(exercise, index);
          },
        ),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  Widget _buildRestTimerOverlay() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFF4A148C), Color(0xFF2D1458), Color(0xFF1A0E38)], begin: Alignment.topLeft, end: Alignment.bottomRight),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("REST", style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white70)),
              Text('$_restSecondsRemaining', style: Theme.of(context).textTheme.displayLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 120)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _finishRest,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF2D1458)),
                child: const Text('Skip Rest'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExercisePage(Exercise exercise, int exerciseIndex) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(exercise.name, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          const SizedBox(height: 10),
          Text(exercise.targetMuscle, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white70)),
          const SizedBox(height: 30),
          FrostedGlassCard(
            child: Column(
              children: List.generate(exercise.sets, (setIndex) {
                bool isSetDone = setIndex < exercise.setsLogged.length;
                return ListTile(
                  leading: Icon(isSetDone ? Icons.check_circle : Icons.radio_button_unchecked, color: isSetDone ? Colors.greenAccent : Colors.white70),
                  title: Text("Set ${setIndex + 1}", style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: isSetDone 
                    ? Text("${exercise.setsLogged[setIndex].reps} reps @ ${exercise.setsLogged[setIndex].weight} kg", style: const TextStyle(color: Colors.white70))
                    : Text("Target: ${exercise.reps} reps", style: const TextStyle(color: Colors.white70)),
                  trailing: ElevatedButton(
                    onPressed: isSetDone ? null : () => _logSet(exerciseIndex, setIndex),
                    style: ElevatedButton.styleFrom(backgroundColor: isSetDone ? Colors.transparent : Colors.white, foregroundColor: const Color(0xFF2D1458)),
                    child: Text(isSetDone ? "DONE" : "LOG"),
                  ),
                );
              }),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    bool isLastExercise = _currentExerciseIndex == _exercises.length - 1;
    bool areAllSetsDone = _exercises[_currentExerciseIndex].setsLogged.length >= _exercises[_currentExerciseIndex].sets;
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      child: ElevatedButton(
        onPressed: areAllSetsDone ? (isLastExercise ? _finishWorkout : _nextExercise) : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white, foregroundColor: const Color(0xFF2D1458),
          disabledBackgroundColor: Colors.white.withOpacity(0.3),
          padding: const EdgeInsets.symmetric(vertical: 15),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: Text(isLastExercise ? 'Finish Workout' : 'Next Exercise'),
      ),
    );
  }
}
