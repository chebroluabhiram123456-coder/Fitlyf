// lib/screens/progress_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitlyf/providers/workout_provider.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // These lines are now corrected
    final provider = Provider.of<WorkoutProvider>(context);
    final weightHistory = provider.weightHistory.entries.toList();
    final totalExercises = provider.allExercises.length;
    final completedExercises = provider.allExercises.where((ex) => ex.isCompleted).length;

    return Scaffold(
      backgroundColor: const Color(0xFF1A0E38),
      appBar: AppBar(
        title: const Text('Analytics'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Progress charts coming soon!',
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
            const SizedBox(height: 40),
            Text(
              'Total Exercises Logged: $totalExercises',
              style: const TextStyle(fontSize: 16, color: Colors.white70),
            ),
            Text(
              'Completed Exercises: $completedExercises',
              style: const TextStyle(fontSize: 16, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}
