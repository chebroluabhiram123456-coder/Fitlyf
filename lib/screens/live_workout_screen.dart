                    import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart'; // We need this for video playback
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
  
  // THE FIX 1: Add a video controller to the state
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    _exercises = widget.workout.exercises.map((ex) {
      return Exercise( id: ex.id, name: ex.name, targetMuscle: ex.targetMuscle, sets: ex.sets, reps: ex.reps, description: ex.description, imageUrl: ex.imageUrl, videoUrl: ex.videoUrl, setsLogged: [] );
    }).toList();
    _pageController = PageController();
    // Initialize video for the first exercise
    _initializeVideoController(0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _restTimer?.cancel();
    // THE FIX 2: Make sure to dispose of the controller to free up resources
    _videoController?.dispose();
    super.dispose();
  }
  
  // THE FIX 3: A new helper function to manage the video controller's lifecycle
  void _initializeVideoController(int index) {
    // Dispose the old controller if it exists
    _videoController?.dispose();
    _videoController = null;

    final videoUrl = _exercises[index].videoUrl;
    if (videoUrl != null && videoUrl.isNotEmpty) {
      _videoController = VideoPlayerController.file(File(videoUrl))
        ..initialize().then((_) {
          // Ensure the first frame is shown and update the UI
          if (mounted) setState(() {});
        });
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentExerciseIndex = index;
    });
    // Initialize a new video controller for the new page
    _initializeVideoController(index);
  }

  // ... All other logic functions (_startRestTimer, _logAllSetsForExercise, etc.) are unchanged ...
  void _startRestTimer() { setState(() { _isResting = true; _restSecondsRemaining = 60; }); _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) { if (_restSecondsRemaining > 0) { setState(() { _restSecondsRemaining--; }); } else { _finishRest(); } }); }
  void _finishRest() { _restTimer?.cancel(); setState(() { _isResting = false; }); }
  void _logAllSetsForExercise(int exerciseIndex) { final exercise = _exercises[exerciseIndex]; final provider = Provider.of<WorkoutProvider>(context, listen: false); final newLogs = List.generate(exercise.sets, (index) { return SetLog(reps: exercise.reps, weight: 50.0); }); setState(() { exercise.setsLogged.addAll(newLogs); }); for (var log in newLogs) { provider.logSet(exercise.id, log.reps, log.weight); } _startRestTimer(); }
  void _nextExercise() { if (_currentExerciseIndex < _exercises.length - 1) { _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut); } else { _finishWorkout(); } }
  void _finishWorkout() { final provider = Provider.of<WorkoutProvider>(context, listen: false); final completedWorkout = Workout(id: widget.workout.id, name: widget.workout.name, exercises: _exercises); provider.logWorkout(provider.selectedDate, completedWorkout); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Workout Complete! Achievement Unlocked: First Workout!"), backgroundColor: Colors.green)); Navigator.of(context).popUntil((route) => route.isFirst); }

  @override
  Widget build(BuildContext context) {
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
          onPageChanged: _onPageChanged, // Use our new handler
          itemBuilder: (context, index) {
            final exercise = _exercises[index];
            return _buildExercisePage(exercise, index);
          },
        ),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  Widget _buildExercisePage(Exercise exercise, int exerciseIndex) {
    final bool isExerciseDone = exercise.setsLogged.length >= exercise.sets;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(exercise.name, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          const SizedBox(height: 10),
          Center(child: Text(exercise.targetMuscle, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white70))),
          const SizedBox(height: 25),

          // THE FIX 4: The new, smart media display section
          _buildMediaDisplay(exercise),

          const SizedBox(height: 25),
          if (exercise.description != null && exercise.description!.isNotEmpty) ...[
            FrostedGlassCard(
              child: Text(exercise.description!, style: const TextStyle(color: Colors.white70, height: 1.5, fontSize: 16)),
            ),
            const SizedBox(height: 25),
          ],
          
          FrostedGlassCard(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                      _buildStatColumn("Sets", exercise.sets.toString()),
                      Container(height: 50, width: 1, color: Colors.white24),
                      _buildStatColumn("Reps", exercise.reps.toString()),
                  ]),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: Icon(isExerciseDone ? Icons.check : Icons.done_all),
                      label: Text(isExerciseDone ? "Completed" : "Mark as Complete"),
                      onPressed: isExerciseDone ? null : () => _logAllSetsForExercise(exerciseIndex),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        backgroundColor: isExerciseDone ? Colors.greenAccent.withOpacity(0.5) : Colors.white,
                        foregroundColor: isExerciseDone ? Colors.white : const Color(0xFF2D1458),
                        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
  
  // THE FIX 5: New helper widget for showing video, image, or a placeholder.
  Widget _buildMediaDisplay(Exercise exercise) {
    bool hasVideo = _videoController != null && _videoController!.value.isInitialized;
    bool hasImage = exercise.imageUrl != null && exercise.imageUrl!.isNotEmpty;

    if (hasVideo) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: AspectRatio(
          aspectRatio: _videoController!.value.aspectRatio,
          child: Stack(
            alignment: Alignment.center,
            children: [
              VideoPlayer(_videoController!),
              IconButton(
                icon: Icon(
                  _videoController!.value.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                  size: 60, color: Colors.white.withOpacity(0.8),
                ),
                onPressed: () {
                  setState(() {
                    _videoController!.value.isPlaying ? _videoController!.pause() : _videoController!.play();
                  });
                },
              ),
            ],
          ),
        ),
      );
    } else if (hasImage) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Image.file(File(exercise.imageUrl!), height: 200, width: double.infinity, fit: BoxFit.cover, errorBuilder: (c, e, s) => _buildMediaPlaceholder()),
      );
    } else {
      return _buildMediaPlaceholder();
    }
  }

  // --- All other widgets are unchanged ---
  Widget _buildMediaPlaceholder() { return Container(height: 200, width: double.infinity, decoration: BoxDecoration(color: Colors.black.withOpacity(0.2), borderRadius: BorderRadius.circular(15)), child: const Center(child: Icon(Icons.image_not_supported_outlined, color: Colors.white38, size: 50))); }
  Widget _buildStatColumn(String label, String value) { return Column(children: [ Text(value, style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold)), const SizedBox(height: 5), Text(label, style: const TextStyle(color: Colors.white70))]); }
  Widget _buildRestTimerOverlay() { return Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF4A148C), Color(0xFF2D1458), Color(0xFF1A0E38)], begin: Alignment.topLeft, end: Alignment.bottomRight)), child: Scaffold(backgroundColor: Colors.transparent, body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [ Text("REST", style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white70)), Text('$_restSecondsRemaining', style: Theme.of(context).textTheme.displayLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 120)), const SizedBox(height: 20), ElevatedButton(onPressed: _finishRest, style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF2D1458)), child: const Text('Skip Rest'))])))); }
  Widget _buildBottomNav() { bool isLastExercise = _currentExerciseIndex == _exercises.length - 1; bool areAllSetsDone = _exercises[_currentExerciseIndex].setsLogged.length >= _exercises[_currentExerciseIndex].sets; return Padding(padding: const EdgeInsets.fromLTRB(20, 10, 20, 30), child: ElevatedButton(onPressed: areAllSetsDone ? (isLastExercise ? _finishWorkout : _nextExercise) : null, style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF2D1458), disabledBackgroundColor: Colors.white.withOpacity(0.3), padding: const EdgeInsets.symmetric(vertical: 15), textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))), child: Text(isLastExercise ? 'Finish Workout' : 'Next Exercise'))); }
}
