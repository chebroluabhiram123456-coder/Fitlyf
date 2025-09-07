import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitlyf/providers/workout_provider.dart';

class WeightDetailScreen extends StatelessWidget {
  const WeightDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutProvider>(
      builder: (context, workoutProvider, child) {
        // *** THIS IS THE FIX: .entries is removed because weightHistory is already a List ***
        final weightHistory = workoutProvider.weightHistory;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Weight History'),
          ),
          body: weightHistory.isEmpty
              ? const Center(child: Text('No weight entries yet.'))
              : ListView.builder(
                  itemCount: weightHistory.length,
                  itemBuilder: (context, index) {
                    final log = weightHistory[index];
                    return ListTile(
                      title: Text('${log.weight.toStringAsFixed(1)} kg'),
                      subtitle: Text('Logged on ${log.date.toLocal().toString().split(' ')[0]}'),
                    );
                  },
                ),
        );
      },
    );
  }
}
