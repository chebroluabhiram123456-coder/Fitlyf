import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitlyf/providers/workout_provider.dart';
import 'package:fitlyf/models/workout_status.dart'; // <-- *** THIS IMPORT WAS MISSING ***

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutProvider>(
      builder: (context, workoutProvider, child) {
        // *** FIX 1: Remove .entries ***
        final weightHistory = workoutProvider.weightHistory;
        final workoutHistory = workoutProvider.workoutLog;

        return Scaffold(
          appBar: AppBar(
            title: const Text('My Progress'),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Text('Weight History (${weightHistory.length} entries)'),
              // You can build your weight history UI here
              const SizedBox(height: 20),
              Text('Workout History (${workoutHistory.length} entries)'),
              // You can build your workout history UI here
              const SizedBox(height: 20),
              _buildExampleStatusWidget(workoutProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildExampleStatusWidget(WorkoutProvider provider) {
    if (provider.workoutLog.isEmpty) return const Text('No workouts logged yet.');
    
    final firstLog = provider.workoutLog.first;
    final status = provider.getWorkoutStatusForDate(firstLog.date);
    
    IconData icon;
    Color iconColor;

    // *** FIX 2: This logic now works because WorkoutStatus is imported ***
    if (status == WorkoutStatus.Completed) {
      icon = Icons.check_circle;
      iconColor = Colors.greenAccent;
    } else if (status == WorkoutStatus.Skipped) {
      icon = Icons.cancel;
      iconColor = Colors.redAccent;
    } else {
      icon = Icons.hourglass_empty;
      iconColor = Colors.grey;
    }

    return Card(
      child: ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(firstLog.workoutName),
        subtitle: const Text('Example Status'),
      ),
    );
  }
}
