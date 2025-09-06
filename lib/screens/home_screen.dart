import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitlyf/providers/workout_provider.dart';
import 'package:fitlyf/widgets/frosted_glass_card.dart';
import 'package.fitlyf/screens/workout_detail_screen.dart';
import 'package.fitlyf/screens/add_exercise_screen.dart';
import 'package.intl/intl.dart';
import 'package.fitlyf/models/workout_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutProvider>(
      builder: (context, workoutProvider, child) {
        final workout = workoutProvider.selectedWorkout;

        // THE FIX: REMOVED THE OUTER CONTAINER WITH THE GRADIENT
        // The Scaffold is now the top-level widget.
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCalendarHeader(context, workoutProvider),
                  const SizedBox(height: 30),
                  const Text(
                    "Get ready, User",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Text(
                    "Here's your plan for ${DateFormat('EEEE').format(workoutProvider.selectedDate)}",
                    style: const TextStyle(fontSize: 18, color: Colors.white70),
                  ),
                  const SizedBox(height: 30),
                  if (workout != null)
                    _buildWorkoutCard(context, workout)
                  else
                    _buildRestDayCard(),
                  const SizedBox(height: 20),
                  _buildWeightTrackerCard(context, workoutProvider),
                  const SizedBox(height: 20),
                  _buildCreateExerciseButton(context),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ... All your other _build... helper methods remain the same ...
  Widget _buildCalendarHeader(BuildContext context, WorkoutProvider provider) {
    final List<DateTime> dates = List.generate(7, (index) {
      final now = DateTime.now();
      return now.subtract(Duration(days: now.weekday - 1)).add(Duration(days: index));
    });
    return SizedBox(
      height: 70,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        itemBuilder: (context, index) {
          final date = dates[index];
          final bool isActive = DateUtils.isSameDay(date, provider.selectedDate);
          return _dateChip(
            day: DateFormat('E').format(date),
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

  Widget _buildRestDayCard() {
    return const FrostedGlassCard(
      child: Center(
        child: Text(
          "It's a Rest Day! 😌",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildCreateExerciseButton(BuildContext context) {
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
            Icon(Icons.add_circle_outline, color: Colors.white, size: 28),
            SizedBox(width: 15),
            Text(
              "Create Your Own Exercise",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Spacer(),
            Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightTrackerCard(BuildContext context, WorkoutProvider provider) {
    return GestureDetector(
      onTap: () => _showLogWeightDialog(context, provider),
      child: FrostedGlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Row(
          children: [
            const Icon(Icons.monitor_weight_outlined, color: Colors.white, size: 28),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Current Weight",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  "${provider.latestWeight} kg",
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
            const Spacer(),
            const Icon(Icons.add, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }

  void _showLogWeightDialog(BuildContext context, WorkoutProvider provider) {
    final TextEditingController controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF3E246E),
          title: const Text('Log Today\'s Weight', style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: controller,
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: "e.g., 73.5",
              hintStyle: TextStyle(color: Colors.white54),
              suffixText: "kg",
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
            ),
            TextButton(
              onPressed: () {
                final double? newWeight = double.tryParse(controller.text);
                if (newWeight != null) {
                  provider.logUserWeight(newWeight);
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
  
  Widget _buildWorkoutCard(BuildContext context, Workout workout) {
     return GestureDetector(
       onTap: () {
          if (workout.exercises.isNotEmpty) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => WorkoutDetailScreen(workout: workout)));
          }
       },
       child: Hero(
        tag: 'workout_card',
        child: FrostedGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                workout.name,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white),
              ),
              const SizedBox(height: 5),
              Text(
                "${workout.exercises.length} exercises",
                style: const TextStyle(fontSize: 16, color: Colors.white70),
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
}
