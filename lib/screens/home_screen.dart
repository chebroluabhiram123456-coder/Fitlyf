import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/workout_provider.dart';
import '../models/workout_session.dart';
import 'workout_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  // Use a key for the widget constructor, which is good practice.
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Access the provider to get the workout data.
    final provider = Provider.of<WorkoutProvider>(context);
    
    // Get the selected workout for the current day. This might be null on a rest day.
    final WorkoutSession? workout = provider.selectedWorkout;

    // The Scaffold provides the main layout structure for the screen.
    return Scaffold(
      appBar: AppBar(
        // The title displayed at the top of the screen.
        title: const Text('FitLyf Dashboard'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // This is a placeholder for a header or date scroller.
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "Today's Workout",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // This is the CRITICAL part of the code.
          // We check if 'workout' is null. If it is, it's a rest day.
          // If it's not null, we show the workout card.
          // This prevents the app from crashing by trying to access properties on a null object.
          if (workout != null)
            _buildWorkoutCard(context, workout)
          else
            _buildRestDayCard(),
            
          // You can add more widgets here if needed.
        ],
      ),
    );
  }

  /// A helper method to build the card for a scheduled workout.
  Widget _buildWorkoutCard(BuildContext context, WorkoutSession workout) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        title: Text(
          workout.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Text('${workout.exercises.length} exercises'),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          // When tapped, navigate to the detail screen, passing the workout data.
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

  /// A helper method to build the card for a rest day.
  Widget _buildRestDayCard() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: const ListTile(
        contentPadding: EdgeInsets.all(16.0),
        leading: Icon(Icons.bedtime, size: 40),
        title: Text(
          "Rest Day",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Text("Time to recover and build muscle!"),
      ),
    );
  }
}
