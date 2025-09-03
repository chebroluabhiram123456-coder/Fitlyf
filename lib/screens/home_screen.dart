import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fitlyf/providers/workout_provider.dart';
import 'package:fitlyf/widgets/frosted_glass_card.dart';
import 'package:fitlyf/screens/workout_detail_screen.dart';
import 'package:fitlyf/screens/add_exercise_screen.dart';
import 'package:fitlyf/models/workout_session.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<DateTime> _dates = List.generate(7, (index) {
    return DateTime.now().subtract(Duration(days: DateTime.now().weekday)).add(Duration(days: index));
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutProvider>(
      builder: (context, provider, child) {
        final workout = provider.selectedWorkout;

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
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCalendarHeader(provider),
                      const SizedBox(height: 30),
                      const Text(
                        "Get ready, AB",
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Here's your plan for ${DateFormat('EEEE').format(provider.selectedDate)}",
                        style: const TextStyle(fontSize: 18, color: Colors.white70),
                      ),
                      const SizedBox(height: 20),
                      _buildWeightLogger(context, provider),
                      const SizedBox(height: 20),
                      _buildWorkoutCard(context, workout, provider),
                      const SizedBox(height: 20),
                      _buildAddExerciseButton(context),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCalendarHeader(WorkoutProvider provider) {
    return SizedBox(
      height: 70,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _dates.length,
        itemBuilder: (context, index) {
          final date = _dates[index];
          final bool isActive = DateUtils.isSameDay(date, provider.selectedDate);
          return _dateChip(
            day: DateFormat('E').format(date).substring(0, 2),
            date: DateFormat('d').format(date),
            isActive: isActive,
            onTap: () {
              provider.changeSelectedDate(date);
            },
          );
        },
      ),
    );
  }

  Widget _dateChip({required String day, required String date, required bool isActive, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          border: isActive ? null : Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(day, style: TextStyle(color: isActive ? Colors.black : Colors.white70, fontSize: 12)),
            const SizedBox(height: 4),
            Text(date, style: TextStyle(color: isActive ? Colors.black : Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightLogger(BuildContext context, WorkoutProvider provider) {
    final todaysWeight = provider.todaysWeight;
    final TextEditingController weightController = TextEditingController();

    void _showEditDialog() {
      weightController.text = todaysWeight?.toString() ?? "";
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: const Color(0xFF2D1458),
            title: const Text('Log Your Weight', style: TextStyle(color: Colors.white)),
            content: TextField(
              controller: weightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: "Enter weight in kg",
                hintStyle: TextStyle(color: Colors.white54),
                suffixText: 'kg',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
              ),
              TextButton(
                onPressed: () {
                  final weight = double.tryParse(weightController.text);
                  if (weight != null) {
                    provider.logWeight(weight);
                    Navigator.pop(context);
                  }
                },
                // REMOVED 'const' because Colors.purple.shade200 is not a constant
                child: Text('Save', style: TextStyle(color: Colors.purple.shade200)),
              ),
            ],
          );
        },
      );
    }

    if (todaysWeight == null) {
      return GestureDetector(
        onTap: _showEditDialog,
        child: FrostedGlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: const Row(
            children: [
              Icon(Icons.scale, color: Colors.white, size: 28),
              SizedBox(width: 15),
              Text(
                "Log Your Today's Weight",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      );
    } else {
      return FrostedGlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.greenAccent, size: 28),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Today's Weight",
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                ),
                Text(
                  "$todaysWeight kg",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white70),
              onPressed: _showEditDialog,
            ),
          ],
        ),
      );
    }
  }

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
    );
  }

  Widget _buildPlanWorkoutView(BuildContext context, WorkoutProvider provider) {
    return Column(
      children: [
        const Text("Nothing planned for today.", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        ElevatedButton(
          onPressed: () => _showMuscleGroupPicker(context, provider),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple.shade200,
            foregroundColor: Colors.black,
          ),
          child: const Text("Plan a Workout"),
        ),
      ],
    );
  }

  void _showMuscleGroupPicker(BuildContext context, WorkoutProvider provider) {
    final List<String> muscleGroups = [
      'Chest', 'Bicep', 'Tricep', 'Shoulder', 'Back', 'Legs', 'Abs', 'Forearms'
    ];
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2D1458),
          title: const Text("What muscle group to target?", style: TextStyle(color: Colors.white)),
          content: Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: muscleGroups.map((group) {
              return ElevatedButton(
                child: Text(group),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple.shade200,
                  foregroundColor: Colors.black,
                ),
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
            Icon(Icons.add, color: Colors.white, size: 28),
            SizedBox(width: 15),
            Text(
              "Add New Exercise to Library",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Spacer(),
            Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
          ],
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
}
