import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:fitlyf/providers/workout_provider.dart';
import 'package:fitlyf/models/workout_model.dart';
import 'package:fitlyf/models/exercise_model.dart';
import 'package:fitlyf/models/set_log_model.dart';
import 'package:fitlyf/widgets/frosted_glass_card.dart';
import 'package:fitlyf/widgets/modern_progress_bar.dart'; // <-- IMPORT THE NEW WIDGET

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
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    _exercises = widget.workout.exercises.map((ex) {
      return Exercise( id: ex.id, name: ex.name, targetMuscle: ex.targetMuscle, sets: ex.sets, reps: ex.reps, description: ex.description, imageUrl: ex.imageUrl, videoUrl: ex.videoUrl, setsLogged: [] );
    }).toList();
    _pageController = PageController();
    _initializeVideoController(0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _restTimer?.cancel();
    _videoController?.dispose();
    super.dispose();
  }
  
  void _initializeVideoController(int index) {
    _videoController?.dispose();
    _videoController = null;
    final videoUrl = _exercises[index].videoUrl;
    if (videoUrl != null && videoUrl.isNotEmpty) {
      _videoController = VideoPlayerController.file(File(videoUrl))
        ..initialize().then((_) { if (mounted) setState(() {}); });
    }
  }

  void _onPageChanged(int index) {
    setState(() { _currentExerciseIndex = index; });
    _initializeVideoController(index);
  }
  
  // ... All other logic functions are unchanged ...
  void _startRestTimer() { setState(() { _isResting = true; _restSecondsRemaining = 60; }); _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) { if (_restSecondsRemaining > 0) { setState(() { _restSecondsRemaining--; }); } else { _finishRest(); } }); }
  void _finishRest() { _restTimer?.cancel(); setState(() { _isResting = false; }); }
  void _logAllSetsForExercise(int exerciseIndex) { final exercise = _exercises[exerciseIndex]; final provider = Provider.of<WorkoutProvider>(context, listen: false); final newLogs = List.generate(exercise.sets, (index) { return SetLog(reps: exercise.reps, weight: 50.0); }); setState(() { exercise.setsLogged.addAll(newLogs); }); for (var log in newLogs) { provider.logSet(exercise.id, log.reps, log.weight); } _startRestTimer(); }
  void _nextExercise() { if (_currentExerciseIndex < _exercises.length - 1) { _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut); } else { _finishWorkout(); } }
  void _finishWorkout() { final provider = Provider.of<WorkoutProvider>(context, listen: false); final completedWorkout = Workout(id: widget.workout.id, name: widget.workout.name, exercises: _exercises); provider.logWorkout(provider.selectedDate, completedWorkout); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Workout Complete! Achievement Unlocked: First Workout!"), backgroundColor: Colors.green)); Navigator.of(context).popUntil((route) => route.isFirst); }

  @override
  Widget build(BuildContext context) {
    if (_isResting) { return _buildRestTimerOverlay(); }
    
    // Calculate progress for the app bar
    final completedCount = _exercises.where((ex) => ex.setsLogged.length >= ex.sets).length;
    final totalCount = _exercises.length;
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;

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
          // THE FIX: Add the progress bar to the AppBar for a clean, modern look.
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(12.0),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
              child: ModernProgressBar(progress: progress),
            ),
          ),
        ),
        body: PageView.builder(
          controller: _pageController,
          itemCount: _exercises.length,
          onPageChanged: _onPageChanged,
          itemBuilder: (context, index) {
            final exercise = _exercises[index];
            return _buildExercisePage(exercise, index);
          },
        ),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }
  
  // ... All other helper methods are unchanged ...
  Widget _buildExercisePage(Exercise exercise, int exerciseIndex) { /* ... */ }
  Widget _buildMediaDisplay(Exercise exercise) { /* ... */ }
  Widget _buildMediaPlaceholder() { /* ... */ }
  Widget _buildStatColumn(String label, String value) { /* ... */ }
  Widget _buildRestTimerOverlay() { /* ... */ }
  Widget _buildBottomNav() { /* ... */ }
}
