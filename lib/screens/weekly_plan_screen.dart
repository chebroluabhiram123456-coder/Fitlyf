// lib/screens/weekly_plan_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitlyf/providers/workout_provider.dart';
import 'package:fitlyf/widgets/frosted_glass_card.dart';

class WeeklyPlanScreen extends StatelessWidget {
  const WeeklyPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Access the provider to get and update workout plans
    final workoutProvider = Provider.of<WorkoutProvider>(context);
    final weeklyPlan = workoutProvider.weeklyPlan;

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
        appBar: AppBar(
          title: const Text('Your Weekly Plan', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: ListView.builder(
          padding: const EdgeInsets.all(20.0),
          itemCount: weeklyPlan.length,
          itemBuilder: (context, index) {
            String day = weeklyPlan.keys.elementAt(index);
            String muscleGroup = weeklyPlan[day]!;

            return Padding(
              padding: const EdgeInsets.only(bottom: 15.0),
              child: FrostedGlassCard(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: Text(
                    day,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  trailing: Text(
                    muscleGroup,
                    style: const TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  onTap: () {
                    // This will open a dialog to edit the muscle group
                    _showEditDialog(context, workoutProvider, day);
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // A dialog box to edit the workout for a specific day
  void _showEditDialog(BuildContext context, WorkoutProvider provider, String day) {
    final TextEditingController controller = TextEditingController(text: provider.weeklyPlan[day]);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF3E246E),
          title: Text('Update Plan for $day', style: const TextStyle(color: Colors.white)),
          content: TextField(
            controller: controller,
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: "e.g., Legs & Back",
              hintStyle: TextStyle(color: Colors.white54),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  provider.updateWeeklyPlan(day, controller.text);
                  Navigator.pop(context);
                }
              },
              child: const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}
