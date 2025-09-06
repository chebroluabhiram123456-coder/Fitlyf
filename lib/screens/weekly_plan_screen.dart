import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitlyf/providers/workout_provider.dart';
import 'package:fitlyf/widgets/frosted_glass_card.dart';

class WeeklyPlanScreen extends StatelessWidget {
  const WeeklyPlanScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutProvider>(
      builder: (context, workoutProvider, child) {
        final weeklyPlan = workoutProvider.weeklyPlan;
        final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

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
              title: const Text('Weekly Plan', style: TextStyle(fontWeight: FontWeight.bold)),
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
            body: ListView.builder(
              padding: const EdgeInsets.all(20.0),
              itemCount: days.length,
              itemBuilder: (context, index) {
                final day = days[index];
                final workoutId = weeklyPlan[day] ?? 'Rest';
                // THE FIX 1: Use the restored helper function for the description.
                final workoutDescription = workoutProvider.getMusclesForWorkout(workoutId);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 15.0),
                  child: FrostedGlassCard(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(day, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                              const SizedBox(height: 5),
                              Text(workoutDescription, style: const TextStyle(fontSize: 16, color: Colors.white70)),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.white70),
                          onPressed: () {
                            _showEditPlanDialog(context, workoutProvider, day);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  // THE FIX 2: Revert the dialog to the simple and reliable DropdownButton.
  void _showEditPlanDialog(BuildContext context, WorkoutProvider provider, String day) {
    String selectedWorkoutId = provider.weeklyPlan[day] ?? 'Rest';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF3E246E),
              title: Text('Edit Plan for $day', style: const TextStyle(color: Colors.white)),
              content: DropdownButton<String>(
                value: selectedWorkoutId,
                isExpanded: true,
                dropdownColor: const Color(0xFF3E246E),
                style: const TextStyle(color: Colors.white, fontSize: 16),
                items: const [
                  DropdownMenuItem(value: 'w1', child: Text('Full Body A')),
                  DropdownMenuItem(value: 'w2', child: Text('Full Body B')),
                  DropdownMenuItem(value: 'Cardio', child: Text('Cardio')),
                  DropdownMenuItem(value: 'Rest', child: Text('Rest')),
                ],
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setDialogState(() {
                      selectedWorkoutId = newValue;
                    });
                  }
                },
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
                ),
                TextButton(
                  onPressed: () {
                    provider.updateWeeklyPlan(day, selectedWorkoutId);
                    Navigator.pop(context);
                  },
                  child: const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          }
        );
      },
    );
  }
}
