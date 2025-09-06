import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fitlyf/models/exercise_model.dart';
import 'package:video_player/video_player.dart'; // We'll need to add this dependency

class ExerciseDetailScreen extends StatefulWidget {
  final Exercise exercise;
  const ExerciseDetailScreen({Key? key, required this.exercise}) : super(key: key);

  @override
  _ExerciseDetailScreenState createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    if (widget.exercise.videoUrl != null && widget.exercise.videoUrl!.isNotEmpty) {
      _videoController = VideoPlayerController.file(File(widget.exercise.videoUrl!))
        ..initialize().then((_) {
          setState(() {}); // Update UI when video is ready
        });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A0E38), // A solid dark background
      appBar: AppBar(
        title: Text(widget.exercise.name),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display Image if available
            if (widget.exercise.imageUrl != null && widget.exercise.imageUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.file(
                  File(widget.exercise.imageUrl!),
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            if (widget.exercise.imageUrl == null)
              Container(
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(Icons.image_not_supported, color: Colors.white38, size: 60),
              ),
            
            const SizedBox(height: 20),
            Text(
              '${widget.exercise.sets} sets x ${widget.exercise.reps} reps',
              style: const TextStyle(fontSize: 18, color: Colors.white70),
            ),
            const SizedBox(height: 10),
            Text(
              'Target Muscle: ${widget.exercise.targetMuscle}',
              style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
            ),
            
            // Video Player
            if (_videoController != null && _videoController!.value.isInitialized) ...[
              const SizedBox(height: 30),
              const Text(
                'Video Tutorial',
                style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              AspectRatio(
                aspectRatio: _videoController!.value.aspectRatio,
                child: VideoPlayer(_videoController!),
              ),
              Center(
                child: IconButton(
                  icon: Icon(
                    _videoController!.value.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                    size: 60,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      _videoController!.value.isPlaying ? _videoController!.pause() : _videoController!.play();
                    });
                  },
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
