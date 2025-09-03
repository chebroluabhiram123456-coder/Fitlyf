import 'package:flutter/material.dart';
import 'package.provider/provider.dart';
// ... (other imports)
import 'package:fitlyf/models/workout_session.dart';

class HomeScreen extends StatefulWidget {
  // ... (StatefulWidget setup remains the same)
}

class _HomeScreenState extends State<HomeScreen> {
  // ... (Date generation remains the same)

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutProvider>(
      builder: (context, provider, child) {
        final workout = provider.selectedWorkout;

        return Container(
          // ... (Gradient decoration remains the same)
          child: Scaffold(
            // ... (Scaffold setup remains the same)
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  // ... (Calendar header and title texts remain the same)
                  children: [
                    _buildWorkoutCard(context, workout, provider),
                    const SizedBox(height: 20),
                    _buildAddExerciseButton(context), // Changed from "Custom Workout"
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ... (_buildCalendarHeader and _dateChip widgets remain the same)
  
  Widget _buildWorkoutCard(BuildContext context, WorkoutSession workout, WorkoutProvider provider) {
    bool isRestDay = workout.exercises.isEmpty;

    return GestureDetector(
      onTap: () {
        if (!isRestDay) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => WorkoutDetailScreen(workout: workout)));
        }
      },
      child: FrostedGlassCard(
        child: isRestDay
            ? _buildPlanWorkoutView(context, provider)
            : Column(
                // ... (The existing workout card UI remains the same)
                children: [
                  Text(
                    workout.name,
                    style: const TextStyle(fontSize: 18, color: Colors.white70),
                  ),
                  // ...
                ],
              ),
      ),
    );
  }

  // NEW: View for when no workout is planned
  Widget _buildPlanWorkoutView(BuildContext context, WorkoutProvider provider) {
    return Column(
      children: [
        const Text("Nothing planned for today.", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        ElevatedButton(
          onPressed: () => _showMuscleGroupPicker(context, provider),
          child: const Text("Plan a Workout"),
          // ... (Style the button to match your UI)
        ),
      ],
    );
  }

  // NEW: Dialog to pick a muscle group for the day's plan
  void _showMuscleGroupPicker(BuildContext context, WorkoutProvider provider) {
    final List<String> muscleGroups = [
      'Chest', 'Bicep', 'Tricep', 'Shoulder', 'Back', 'Legs', 'Abs', 'Forearms'
    ];
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          // ... (Style the dialog to match your UI)
          title: const Text("What muscle group to target?"),
          content: Wrap(
            spacing: 8.0,
            children: muscleGroups.map((group) {
              return ElevatedButton(
                child: Text(group),
                onPressed: () {
                  provider.createWorkoutForDay(provider.selectedDate, group);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }
  
  Widget _buildAddExerciseButton(BuildContext context) {
    // This button now adds an exercise to your library
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddExerciseScreen()),
        );
      },
      child: FrostedGlassCard(
        // ... (Style remains the same, but you might want to change the text)
        child: const Row(
          children: [
            Icon(Icons.add, color: Colors.white, size: 28),
            SizedBox(width: 15),
            Text(
              "Add New Exercise to Library",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            // ...
          ],
        ),
      ),
    );
  }

  // ... (_tag widget remains the same)
}
