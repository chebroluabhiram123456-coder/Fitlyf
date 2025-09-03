import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitlyf/providers/workout_provider.dart';
import 'package:fitlyf/widgets/frosted_glass_card.dart';
import 'package:fitlyf/screens/workout_detail_screen.dart';
import 'package:fitlyf/screens/add_exercise_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final workoutProvider = Provider.of<WorkoutProvider>(context);
    final workout = workoutProvider.todaysWorkout;

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
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCalendarHeader(),
                const SizedBox(height: 30),
                const Text(
                  "Get ready, AB",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const Text(
                  "Let's smash today's workout!",
                  style: TextStyle(fontSize: 18, color: Colors.white70),
                ),
                const SizedBox(height: 30),
                _buildWorkoutCard(context, workout),
                const SizedBox(height: 20),
                _buildCustomWorkoutButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _dateChip("Su", "10", false),
        _dateChip("Mo", "11", true),
        _dateChip("Tu", "12", false),
        _dateChip("We", "13", false),
        _dateChip("Th", "14", false),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.more_horiz, color: Colors.white),
        )
      ],
    );
  }

  Widget _dateChip(String day, String date, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        children: [
          Text(day, style: TextStyle(color: isActive ? Colors.black : Colors.white70, fontSize: 12)),
          const SizedBox(height: 4),
          Text(date, style: TextStyle(color: isActive ? Colors.black : Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }
  
  Widget _buildWorkoutCard(BuildContext context, var workout) {
     return GestureDetector(
       onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => WorkoutDetailScreen(workout: workout)));
       },
       child: Hero(
        tag: 'workout_card',
        child: FrostedGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _tag("Special for AB", Colors.purple.shade300),
                  const SizedBox(width: 8),
                  _tag("Gym", Colors.grey.shade700),
                ],
              ),
              const SizedBox(height: 15),
              const Text(
                "60 min",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white),
              ),
              Text(
                workout.name,
                style: const TextStyle(fontSize: 18, color: Colors.white70),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_forward, color: Colors.white),
                  ),
                ],
              )
            ],
          ),
        ),
       ),
     );
  }

  Widget _tag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }
  
  Widget _buildCustomWorkoutButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddExerciseScreen()),
        );
      },
      child: FrostedGlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: const Row(
          children: [
            Icon(Icons.tune, color: Colors.white, size: 28),
            SizedBox(width: 15),
            Text(
              "Custom Workout",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Spacer(),
            Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
          ],
        ),
      ),
    );
  }
}
