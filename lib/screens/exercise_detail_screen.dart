import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fitlyf/models/exercise_model.dart';
// THE FIX: Add the two missing import statements.
import 'package:video_player/video_player.dart';
import 'package:fitlyf/widgets/frosted_glass_card.dart';

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
          if (mounted) setState(() {});
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
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.exercise.name,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                widget.exercise.targetMuscle,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white70),
              ),
              
              if (widget.exercise.description != null && widget.exercise.description!.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text(
                  widget.exercise.description!,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white70, height: 1.5),
                ),
              ],
              
              const SizedBox(height: 30),
              _buildSetsAndRepsCard(),
              _buildMediaSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSetsAndRepsCard() {
    return FrostedGlassCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatColumn("Sets", widget.exercise.sets.toString()),
          Container(height: 50, width: 1, color: Colors.white24),
          _buildStatColumn("Reps", widget.exercise.reps.toString()),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(value, style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(color: Colors.white70)),
      ],
    );
  }

  Widget _buildMediaSection() {
    bool hasImage = widget.exercise.imageUrl != null && widget.exercise.imageUrl!.isNotEmpty;
    bool hasVideo = _videoController != null && _videoController!.value.isInitialized;

    if (!hasImage && !hasVideo) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 30),
        if (hasVideo) ...[
          Text("Video", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          ClipRRect(
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
          ),
        ] else if (hasImage) ...[
          Text("Image", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.file(
              File(widget.exercise.imageUrl!),
              height: 200, width: double.infinity, fit: BoxFit.cover,
            ),
          ),
        ],
      ],
    );
  }
}
