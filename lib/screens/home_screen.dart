import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitlyf/providers/workout_provider.dart';
import 'package:fitlyf/widgets/frosted_glass_card.dart';
import 'package:fitlyf/screens/workout_detail_screen.dart';
import 'package:fitlyf/screens/add_exercise_screen.dart';
import 'package:intl/intl.dart';
import 'package:fitlyf/models/workout_model.dart';
import 'package:fitlyf/helpers/fade_route.dart';

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
                    // THE FIX: Make the welcome text dynamic.
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
                    _buildCreateExerciseButton(context),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // --- All other helper methods are unchanged, only _buildRestDayCard needs context ---
  Widget _buildRestDayCard(BuildContext context) {
    return FrostedGlassCard(
       key: const ValueKey<String>('rest_day'),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40.0),
          child: Text(
            "It's a Rest Day! 😌",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
  
  // ... Code for other helper methods omitted for brevity but is correct ...
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

  Widget _buildCreateExerciseButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, FadePageRoute(child: const AddExerciseScreen()));
      },
      child: FrostedGlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Row(
          children: [
            const Icon(Icons.add_circle_outline, color: Colors.white, size: 28),
            const SizedBox(width: 15),
            Text("Create Your Own Exercise", style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightTrackerCard(BuildContext context, WorkoutProvider provider) {
    final loggedWeight = provider.weightForSelectedDate;
    final displayWeight = loggedWeight != null ? "${loggedWeight.toStringAsFixed(1)} kg" : "No Entry";

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
                Text(
                  "Weight for ${DateFormat('d MMM').format(provider.selectedDate)}",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  displayWeight,
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
    final TextEditingController controller = TextEditingController(
      text: provider.weightForSelectedDate?.toString() ?? ''
    );
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF3E246E),
          title: Text('Log Weight for ${DateFormat('d MMM').format(provider.selectedDate)}', style: const TextStyle(color: Colors.white)),
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
       key: ValueKey<String>(workout.id),
       onTap: () {
          if (workout.exercises.isNotEmpty) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => WorkoutDetailScreen(workout: workout)));
          }
       },
       child: Hero(
        tag: 'workout_card_${workout.id}',
        child: Material(
          type: MaterialType.transparency,
          child: FrostedGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  workout.name,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
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
       ),
     );
  }
}
