// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/workout_provider.dart';
import '../models/workout_session.dart';
import 'workout_detail_screen.dart'; // Make sure this import exists

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WorkoutProvider>(context);
    final workout = provider.selectedWorkout;

    return Scaffold(
      appBar: AppBar(
        title: Text('FitLyf Dashboard'),
      ),
      body: Column(
        children: [
          // Other widgets like your date scroller would go here...
          
          // FIX: Check if workout is null (a rest day) before building the card.
          if (workout != null)
            _buildWorkoutCard(context, workout)
          else
            _buildRestDayCard(),
        ],
      ),
    );
  }

  Widget _buildWorkoutCard(BuildContext context, WorkoutSession workout) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: ListTile(
        title: Text(workout.name),
        subtitle: Text('${workout.exercises.length} exercises'),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: () {
          // FIX: Pass the non-null workout to the detail screen.
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WorkoutDetailScreen(workout: workout),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRestDayCard() {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: ListTile(
        title: Text("Rest Day"),
        subtitle: Text("Time to recover!"),
      ),
    );
  }
}
