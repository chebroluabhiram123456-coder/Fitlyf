import 'package:flutter/material.dart';
import 'package:fitlyf/models/workout_model.dart';
import 'package:fitlyf/models/exercise_model.dart';

class LiveWorkoutScreen extends StatefulWidget {
  final Workout workout;

  const LiveWorkoutScreen({super.key, required this.workout});

  @override
  State<LiveWorkoutScreen> createState() => _LiveWorkoutScreenState();
}

class _LiveWorkoutScreenState extends State<LiveWorkoutScreen> {
  late PageController _pageController;
  int _currentExerciseIndex = 0;
  bool _isResting = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentExerciseIndex = index;
    });
  }

  void _goToNextExercise() {
    if (_currentExerciseIndex < widget.workout.exercises.length - 1) {
      setState(() { _isResting = true; });
      Future.delayed(const Duration(seconds: 2), () {
        setState(() { _isResting = false; });
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
      });
    } else {
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Workout Complete!'),
        content: const Text('Great job finishing your workout!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Finish'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.workout.name.toUpperCase(),
                            style: const TextStyle(color: Colors.white70, fontSize: 14, letterSpacing: 1.5),
                          ),
                          Text(
                            'Exercise ${_currentExerciseIndex + 1} of ${widget.workout.exercises.length}',
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white, size: 30),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    itemCount: widget.workout.exercises.length,
                    itemBuilder: (context, index) {
                      return _buildExercisePage(widget.workout.exercises[index], index);
                    },
                  ),
                ),
                _buildBottomNav(),
              ],
            ),
          ),
          if (_isResting) _buildRestTimerOverlay(),
        ],
      ),
    );
  }

  Widget _buildExercisePage(Exercise exercise, int exerciseIndex) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 4,
            child: _buildMediaDisplay(exercise),
          ),
          const SizedBox(height: 20),
          Text(
            exercise.name,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatColumn('Sets', exercise.sets.toString()),
              _buildStatColumn('Reps', exercise.reps.toString()),
            ],
          ),
          const Spacer(),
        ],
      ),
    );
  }
  
  // --- THIS FUNCTION IS NOW CORRECTED ---
  Widget _buildMediaDisplay(Exercise exercise) {
    // Prioritize video, then image, then show placeholder
    if (exercise.videoUrl != null && exercise.videoUrl!.isNotEmpty) {
      // TODO: Replace this with a real video player widget
      return _buildMediaPlaceholder(icon: Icons.play_circle_outline);
    } else if (exercise.imageUrl != null && exercise.imageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.network(
          exercise.imageUrl!, // Using the correct 'imageUrl' property
          fit: BoxFit.cover,
          width: double.infinity,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(child: CircularProgressIndicator());
          },
          errorBuilder: (context, error, stackTrace) {
            return _buildMediaPlaceholder(icon: Icons.image_not_supported_outlined);
          },
        ),
      );
    }
    // Fallback if no media is available
    return _buildMediaPlaceholder();
  }

  Widget _buildMediaPlaceholder({IconData icon = Icons.fitness_center}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Icon(
          icon,
          color: Colors.white30,
          size: 100,
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 4),
        Text(label.toUpperCase(), style: const TextStyle(fontSize: 14, color: Colors.white70, letterSpacing: 1.2)),
      ],
    );
  }

  Widget _buildRestTimerOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.85),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("TAKE A REST", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 2)),
            SizedBox(height: 20),
            Text("15s", style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.greenAccent)),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    bool isLastExercise = _currentExerciseIndex == widget.workout.exercises.length - 1;
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: ElevatedButton(
        onPressed: _goToNextExercise,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.greenAccent,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: Text(isLastExercise ? 'Finish Workout' : 'Next Exercise'),
      ),
    );
  }
}
