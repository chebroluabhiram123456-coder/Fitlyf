import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fitlyf/providers/workout_provider.dart';
import 'package:fitlyf/widgets/frosted_glass_card.dart';
import 'package:fitlyf/screens/workout_detail_screen.dart';
import 'package:fitlyf/models/workout_model.dart';
import 'package:fitlyf/helpers/fade_route.dart';
import 'package:fitlyf/screens/add_exercise_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutProvider>(
      builder: (context, workoutProvider, child) {
        final workout = workoutProvider.selectedWorkout;

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCalendarHeader(context, workoutProvider),
                    const SizedBox(height: 30),
                    Text(
                      "Get ready, ${workoutProvider.userName}",
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Here's your plan for ${DateFormat('EEEE').format(workoutProvider.selectedDate)}",
                      style: const TextStyle(fontSize: 18, color: Colors.white70),
                    ),
                    const SizedBox(height: 30),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        return SizeTransition(
                          sizeFactor: animation,
                          child: FadeTransition(opacity: animation, child: child),
                        );
                      },
                      child: workout != null
                          ? _buildWorkoutCard(context, workout)
                          : _buildRestDayCard(context),
                    ),
                    const SizedBox(height: 20),
                    _buildWeightTrackerCard(context, workoutProvider),
                    const SizedBox(height: 20),
                    _buildStreakCard(context, workoutProvider),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStreakCard(BuildContext context, WorkoutProvider provider) {
    final streakCount = provider.weeklyStreakCount;
    // THE FIX: Use the correct getter from the provider.
    final totalWorkouts = provider.weeklyWorkoutDaysCount;
    final message = provider.streakMessage;

    return FrostedGlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        children: [
          Icon(Icons.local_fire_department_rounded, color: streakCount > 0 ? Colors.orangeAccent : Colors.white38, size: 40),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Day $streakCount / $totalWorkouts", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                Text(message, style: const TextStyle(fontSize: 14, color: Colors.white70)),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // ... All other helper methods are unchanged and correct ...
  Widget _buildWorkoutCard(BuildContext context, Workout workout) { /* ... */ }
  Widget _buildCalendarHeader(BuildContext context, WorkoutProvider provider) { /* ... */ }
  Widget _buildRestDayCard(BuildContext context) { /* ... */ }
  Widget _buildWeightTrackerCard(BuildContext context, WorkoutProvider provider) { /* ... */ }
  void _showLogWeightDialog(BuildContext context, WorkoutProvider provider) { /* ... */ }
  Widget _dateChip(BuildContext context, {required String day, required String date, required bool isActive, required VoidCallback onTap}) { /* ... */ }
}
