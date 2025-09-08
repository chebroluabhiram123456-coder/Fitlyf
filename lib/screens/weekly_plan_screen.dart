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
        return Scaffold(
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
              final muscleGroups = weeklyPlan[day] ?? ['Rest'];
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
                            Text(muscleGroups.join(' & '), style: const TextStyle(fontSize: 16, color: Colors.white70)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white70),
                        onPressed: () => _showEditPlanDialog(context, workoutProvider, day),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showEditPlanDialog(BuildContext context, WorkoutProvider provider, String day) {
    List<String> selectedMuscles = List.from(provider.weeklyPlan[day] ?? []);
    final availableMuscles = provider.availableMuscleGroups;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF3E246E),
              title: Text('Edit Plan for $day', style: const TextStyle(color: Colors.white)),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView(
                  shrinkWrap: true,
                  children: availableMuscles.map((muscle) {
                    return CheckboxListTile(
                      title: Text(muscle, style: const TextStyle(color: Colors.white)),
                      value: selectedMuscles.contains(muscle),
                      activeColor: Colors.white,
                      checkColor: const Color(0xFF3E246E),
                      onChanged: (bool? value) {
                        setDialogState(() {
                          if (value == true) {
                            if (muscle == 'Rest') { selectedMuscles = ['Rest']; }
                            else { selectedMuscles.remove('Rest'); selectedMuscles.add(muscle); }
                          } else {
                            selectedMuscles.remove(muscle);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
                ),
                TextButton(
                  onPressed: () {
                    if (selectedMuscles.isEmpty) selectedMuscles.add('Rest');
                    provider.updateWeeklyPlan(day, selectedMuscles);
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
