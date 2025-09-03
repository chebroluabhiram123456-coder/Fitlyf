import 'package:flutter/material.dart';
import 'package:fitlyf/widgets/frosted_glass_card.dart';
import 'package.intl/intl.dart';

class WeeklyPlanScreen extends StatefulWidget {
  const WeeklyPlanScreen({super.key});

  @override
  State<WeeklyPlanScreen> createState() => _WeeklyPlanScreenState();
}

class _WeeklyPlanScreenState extends State<WeeklyPlanScreen> {
  // In a real app, this data would come from a provider or database
  final Map<String, String> _weeklyPlan = {
    'Monday': 'Chest & Triceps',
    'Tuesday': 'Back & Biceps',
    'Wednesday': 'Legs & Shoulders',
    'Thursday': 'Rest Day',
    'Friday': 'Full Body',
    'Saturday': 'Cardio',
    'Sunday': 'Rest Day',
  };

  @override
  Widget build(BuildContext context) {
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
          itemCount: _weeklyPlan.length,
          itemBuilder: (context, index) {
            String day = _weeklyPlan.keys.elementAt(index);
            String workout = _weeklyPlan.values.elementAt(index);
            bool isToday = DateFormat('EEEE').format(DateTime.now()) == day;

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
                            day,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isToday ? Colors.purple.shade200 : Colors.white,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            workout,
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
                        // Logic to edit the plan for this day
                        _showEditDialog(day, workout);
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

  void _showEditDialog(String day, String currentWorkout) {
    final TextEditingController controller = TextEditingController(text: currentWorkout);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2D1458),
          title: Text('Edit plan for $day', style: const TextStyle(color: Colors.white)),
          content: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: "e.g., Chest & Triceps or Rest Day",
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
                  setState(() {
                    _weeklyPlan[day] = controller.text;
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Save', style: TextStyle(color: Colors.purple.shade200)),
            ),
          ],
        );
      },
    );
  }
}
