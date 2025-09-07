import 'package:flutter/material.dart';
import 'package:fitlyf/models/workout_model.dart';
import 'package:fitlyf/models/exercise_model.dart';

// A simple placeholder for video player if you use one
// import 'package:video_player/video_player.dart';

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
  // TODO: Add a timer for rest periods

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
      // TODO: Start rest timer here
      setState(() {
        _isResting = true;
      });
      // For now, we'll just go to the next page after a delay
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _isResting = false;
        });
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
      });
    } else {
      // Last exercise, show completion dialog
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
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back from workout screen
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
                // Top Header
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
                // Main content area
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
                // Bottom Navigation / Action buttons
                _buildBottomNav(),
              ],
            ),
          ),
          if (_isResting) _buildRestTimerOverlay(),
        ],
      ),
    );
  }

  // --- WIDGET BUILDER FUNCTIONS (FIXED) ---

  Widget _buildActionButtons(BuildContext context) {
    // This provides a "Next Exercise" or "Finish Workout" button
    bool isLastExercise = _currentExerciseIndex == widget.workout.exercises.length - 1;
    return ElevatedButton(
      onPressed: _goToNextExercise,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.greenAccent,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: Text(isLastExercise ? 'Finish Workout' : 'Next Exercise'),
    );
  }

  Widget _buildExercisePage(Exercise exercise, int exerciseIndex) {
    // This is the main view for a single exercise
    return Container(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Media Display
          Expanded(
            flex: 4,
            child: _buildMediaDisplay(exercise),
          ),
          const SizedBox(height: 20),
          // Exercise Name
          Text(
            exercise.name,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 20),
          // Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatColumn('Sets', exercise.sets.toString()),
              _buildStatColumn('Reps', exercise.reps.toString()),
              _buildStatColumn('Weight', '${exercise.weight.toStringAsFixed(1)} kg'),
            ],
          ),
          const Spacer(), // Pushes content up
        ],
      ),
    );
  }

  Widget _buildMediaDisplay(Exercise exercise) {
    // Handles showing an image, video, or a placeholder.
    // NOTE: This assumes `exercise.mediaUrl` is a String URL.
    if (exercise.mediaUrl != null && exercise.mediaUrl!.isNotEmpty) {
      // You can add more complex logic here for video vs. image
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.network(
          exercise.mediaUrl!,
          fit: BoxFit.cover,
          width: double.infinity,
          // Loading and error builders are good practice
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(child: CircularProgressIndicator());
          },
          errorBuilder: (context, error, stackTrace) {
            return _buildMediaPlaceholder();
          },
        ),
      );
    }
    return _buildMediaPlaceholder();
  }

  Widget _buildMediaPlaceholder() {
    // A placeholder for when there's no image or video
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: Icon(
          Icons.fitness_center,
          color: Colors.white30,
          size: 100,
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    // A reusable column for displaying a single stat
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 4),
        Text(
          label.toUpperCase(),
          style: const TextStyle(fontSize: 14, color: Colors.white70, letterSpacing: 1.2),
        ),
      ],
    );
  }

  Widget _buildRestTimerOverlay() {
    // An overlay shown during rest periods
    return Container(
      color: Colors.black.withOpacity(0.85),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "TAKE A REST",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 2),
            ),
            SizedBox(height: 20),
            // TODO: Replace with a real countdown timer widget
            Text(
              "15s",
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.greenAccent),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    // The bottom section containing action buttons
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
      child: _buildActionButtons(context),
    );
  }
}
