import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitlyf/providers/workout_provider.dart';
import 'package:fitlyf/models/workout_status.dart'; // <-- *** THE MISSING IMPORT ***
import 'package:intl/intl.dart';


class WorkoutHistoryScreen extends StatefulWidget {
  const WorkoutHistoryScreen({super.key});

  @override
  State<WorkoutHistoryScreen> createState() => _WorkoutHistoryScreenState();
}

class _WorkoutHistoryScreenState extends State<WorkoutHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutProvider>(
      builder: (context, provider, child) {
        // This now correctly references the getter 'workoutLog'
        final loggedWorkouts = provider.workoutLog; 
        
        return Scaffold(
          appBar: AppBar(
            title: const Text('Workout History'),
            backgroundColor: Colors.grey[900],
          ),
          backgroundColor: Colors.black,
          body: ListView.builder(
            itemCount: loggedWorkouts.length,
            itemBuilder: (context, index) {
              final log = loggedWorkouts[index];
              final date = log.date;
              // This now correctly calls the method 'getWorkoutStatusForDate'
              final status = provider.getWorkoutStatusForDate(date); 

              IconData iconData;
              Color iconColor;

              // This logic will now work because WorkoutStatus is imported and defined
              if (status == WorkoutStatus.Completed) {
                iconData = Icons.check_circle;
                iconColor = Colors.greenAccent;
              } else if (status == WorkoutStatus.Skipped) {
                iconData = Icons.cancel;
                iconColor = Colors.redAccent;
              } else {
                iconData = Icons.hourglass_empty;
                iconColor = Colors.grey;
              }

              return ListTile(
                leading: Icon(iconData, color: iconColor),
                title: Text(log.workoutName, style: const TextStyle(color: Colors.white)),
                subtitle: Text(DateFormat('EEEE, d MMM yyyy').format(date), style: const TextStyle(color: Colors.white70)),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.grey),
                  onPressed: () {
                    // This now correctly calls the 'deleteLoggedWorkout' method
                    provider.deleteLoggedWorkout(date); 
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}
