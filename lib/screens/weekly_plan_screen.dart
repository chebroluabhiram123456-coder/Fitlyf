import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitlyf/providers/workout_provider.dart';
import 'package:fitlyf/models/workout_model.dart';

class WeeklyPlanScreen extends StatelessWidget {
  const WeeklyPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutProvider>(
      builder: (context, provider, child) {
        final weeklyPlan = provider.weeklyPlan;
        final allWorkouts = provider.allWorkouts;
        final daysOfWeek = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            title: const Text('Weekly Plan'),
            backgroundColor: Colors.grey[900],
          ),
          body: ListView.separated(
            itemCount: daysOfWeek.length,
            separatorBuilder: (context, index) => Divider(color: Colors.grey[800], height: 1),
            itemBuilder: (context, index) {
              final day = daysOfWeek[index];
              final assignedWorkoutId = weeklyPlan[day];
              
              Workout? assignedWorkout;
              if (assignedWorkoutId != null) {
                // *** THIS IS THE LOGIC FIX ***
                // Using a try-catch block is the safest way to find the workout.
                try {
                  assignedWorkout = allWorkouts.firstWhere((w) => w.id == assignedWorkoutId);
                } catch (e) {
                  assignedWorkout = null; // If not found, it remains null.
                }
              }

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                leading: Text(day, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                title: Text(
                  assignedWorkout?.name ?? 'Rest Day',
                  style: TextStyle(color: assignedWorkout != null ? Colors.greenAccent : Colors.white70, fontSize: 18),
                ),
                subtitle: assignedWorkout != null 
                  ? Text('${assignedWorkout.exercises.length} exercises', style: const TextStyle(color: Colors.white54)) 
                  : null,
                trailing: const Icon(Icons.edit, color: Colors.white30),
                onTap: () {
                  _showWorkoutSelectionDialog(context, provider, day);
                },
              );
            },
          ),
        );
      },
    );
  }

  void _showWorkoutSelectionDialog(BuildContext context, WorkoutProvider provider, String day) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text('Select Workout for $day', style: const TextStyle(color: Colors.white)),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: provider.allWorkouts.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return ListTile(
                    title: const Text('Rest Day', style: TextStyle(color: Colors.white70)),
                    onTap: () {
                      provider.updateWeeklyPlan(day, null);
                      Navigator.of(dialogContext).pop();
                    },
                  );
                }
                final workout = provider.allWorkouts[index - 1];
                return ListTile(
                  title: Text(workout.name, style: const TextStyle(color: Colors.white)),
                  onTap: () {
                    provider.updateWeeklyPlan(day, workout.id);
                    Navigator.of(dialogContext).pop();
                  },
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: Colors.white)),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
          ],
        );
      },
    );
  }
}
