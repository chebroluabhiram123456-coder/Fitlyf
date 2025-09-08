import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitlyf/providers/workout_provider.dart';
import 'package:fitlyf/widgets/frosted_glass_card.dart';

class WeeklyPlanScreen extends StatelessWidget {
  const WeeklyPlanScreen({super.key});

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
                // Get the list of muscles for the current day
                final assignedMuscles = weeklyPlan[day] ?? [];
                
                // Format the description text
                String workoutDescription;
                if (assignedMuscles.isEmpty) {
                  workoutDescription = 'Rest';
                } else {
                  workoutDescription = assignedMuscles.join(', '); // e.g., "Chest, Triceps"
                }

                // Your original, beautiful FrostedGlassCard UI
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
                              Text(
                                day,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                workoutDescription,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.white70),
                          onPressed: () {
                            // Open the new multi-select dialog
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

  // This is the new, upgraded dialog for multi-selecting muscles
  void _showEditPlanDialog(BuildContext context, WorkoutProvider provider, String day) {
    // Create a temporary list to hold the user's selections inside the dialog
    List<String> selectedMuscles = List.from(provider.weeklyPlan[day] ?? []);

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
                // Use a SingleChildScrollView to prevent overflow if you have many muscles
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Add a "Rest Day" option
                      CheckboxListTile(
                        title: const Text('Rest Day', style: TextStyle(color: Colors.white70)),
                        value: selectedMuscles.isEmpty || selectedMuscles.contains('Rest'),
                        activeColor: Theme.of(context).colorScheme.secondary,
                        onChanged: (bool? value) {
                          setDialogState(() {
                            if (value == true) {
                              selectedMuscles = ['Rest'];
                            } else {
                              selectedMuscles.remove('Rest');
                            }
                          });
                        },
                      ),
                      const Divider(color: Colors.white24),
                      // Create a checkbox for each available muscle group
                      ...provider.availableMuscleGroups.map((muscle) {
                        return CheckboxListTile(
                          title: Text(muscle, style: const TextStyle(color: Colors.white)),
                          value: selectedMuscles.contains(muscle),
                          activeColor: Theme.of(context).colorScheme.secondary,
                          onChanged: (bool? value) {
                            setDialogState(() {
                              // Logic to handle multi-selection
                              selectedMuscles.remove('Rest'); // Unselect rest if a muscle is chosen
                              if (value == true) {
                                selectedMuscles.add(muscle);
                              } else {
                                selectedMuscles.remove(muscle);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
                ),
                TextButton(
                  onPressed: () {
                    // Call the provider to save the user's final selections
                    provider.updateWeeklyPlan(day, selectedMuscles);
                    Navigator.pop(context);
                  },
                  child: const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
