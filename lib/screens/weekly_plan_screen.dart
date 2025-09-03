import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitlyf/providers/workout_provider.dart';
import 'package:fitlyf/widgets/frosted_glass_card.dart';
import 'package:intl/intl.dart';

class WeeklyPlanScreen extends StatelessWidget {
  const WeeklyPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WorkoutProvider>(context);
    final weeklyPlan = provider.weeklyPlan;
    final weekdays = [ 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday' ];

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
          title: const Text('Weekly Plan'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: weekdays.length,
          itemBuilder: (context, index) {
            final dayIndex = index + 1; // 1 for Monday, etc.
            final dayName = weekdays[index];
            final workoutList = weeklyPlan[dayIndex] ?? ['Rest Day'];
            final workoutText = workoutList.join(' & ');
            final bool isToday = DateFormat('EEEE').format(DateTime.now()) == dayName;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: FrostedGlassCard(
                borderRadius: BorderRadius.circular(15),
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dayName,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isToday ? Colors.purple.shade200 : Colors.white,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            workoutText,
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
                        _showEditDialog(context, provider, dayIndex, workoutList);
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
  }

  void _showEditDialog(BuildContext context, WorkoutProvider provider, int dayIndex, List<String> currentSelection) {
    final List<String> muscleGroups = ['Chest', 'Bicep', 'Tricep', 'Shoulder', 'Back', 'Legs', 'Abs', 'Forearms'];
    
    // Use a temporary list to hold changes within the dialog
    List<String> tempSelection = List.from(currentSelection.where((e) => e != 'Rest Day'));

    showDialog(
      context: context,
      builder: (context) {
        // Use a StatefulWidget to manage the state of the dialog's checkboxes
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF2D1458),
              title: const Text('Select Muscle Groups', style: TextStyle(color: Colors.white)),
              content: SingleChildScrollView(
                child: Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: muscleGroups.map((muscle) {
                    final bool isSelected = tempSelection.contains(muscle);
                    return FilterChip(
                      label: Text(muscle),
                      selected: isSelected,
                      onSelected: (bool selected) {
                        setDialogState(() {
                          if (selected) {
                            tempSelection.add(muscle);
                          } else {
                            tempSelection.remove(muscle);
                          }
                        });
                      },
                      backgroundColor: Colors.white.withOpacity(0.1),
                      selectedColor: Colors.purple.shade200,
                      labelStyle: TextStyle(color: isSelected ? Colors.black : Colors.white),
                      checkmarkColor: Colors.black,
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
                    provider.updateWeeklyPlan(dayIndex, tempSelection);
                    Navigator.pop(context);
                  },
                  child: Text('Save', style: TextStyle(color: Colors.purple.shade200)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
