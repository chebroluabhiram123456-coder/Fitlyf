import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fitlyf/providers/workout_provider.dart';
import 'package:fitlyf/widgets/frosted_glass_card.dart';
import 'package:fitlyf/screens/workout_detail_screen.dart';
import 'package:fitlyf/models/workout_model.dart';

// A reusable animation wrapper to keep the code clean
class FadeSlideIn extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final double delay;

  const FadeSlideIn({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    this.delay = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, double value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 30), // Slide up effect
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      // The SingleChildScrollView MUST be the direct body to handle all scrolling and insets
      body: SingleChildScrollView(
        primary: true, // This correctly handles safe area insets for scrolling content
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Consumer<WorkoutProvider>(
            builder: (context, workoutProvider, child) {
              final workout = workoutProvider.workoutForSelectedDate;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // FIX 1: Added space above the calendar to push it down
                  const SizedBox(height: 10), 
                  
                  _buildCalendarHeader(context, workoutProvider),
                  const SizedBox(height: 30),

                  // Animating the welcome text
                  FadeSlideIn(
                    child: Text(
                      "Get ready, ${workoutProvider.userName}",
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  FadeSlideIn(
                    delay: 0.1, // Slight delay for effect
                    child: Text(
                      "Here's your plan for ${DateFormat('EEEE').format(workoutProvider.selectedDate)}",
                      style: const TextStyle(fontSize: 18, color: Colors.white70),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // FIX 2: Restored and enhanced animations
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 600),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SizeTransition(
                          sizeFactor: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
                          child: child,
                        ),
                      );
                    },
                    child: workout != null ? _buildWorkoutCard(context, workout) : _buildRestDayCard(context),
                  ),
                  const SizedBox(height: 20),
                  FadeSlideIn(
                    delay: 0.2,
                    child: _buildWeightTrackerCard(context, workoutProvider),
                  ),

                  // Final padding at the bottom to ensure nothing touches the edge
                  const SizedBox(height: 20),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildWorkoutCard(BuildContext context, Workout workout) {
     return GestureDetector(
       // The key is crucial for AnimatedSwitcher to detect a change
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
                Text(workout.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white)),
                const SizedBox(height: 5),
                Text("${workout.exercises.length} exercises", style: const TextStyle(fontSize: 16, color: Colors.white70)),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
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

  Widget _buildCalendarHeader(BuildContext context, WorkoutProvider provider) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final List<DateTime> dates = List.generate(7, (index) => startOfWeek.add(Duration(days: index)));

    return SizedBox(
      height: 70,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        itemBuilder: (context, index) {
          final date = dates[index];
          final bool isActive = DateUtils.isSameDay(date, provider.selectedDate);
          return _dateChip(context, day: DateFormat('E').format(date), date: DateFormat('d').format(date), isActive: isActive, onTap: () { provider.changeSelectedDate(date); });
        },
      ),
    );
  }

  Widget _buildRestDayCard(BuildContext context) {
    return FrostedGlassCard(
      // The key is crucial for AnimatedSwitcher to detect a change
      key: const ValueKey<String>('rest_day'),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40.0),
          child: Text("It's a Rest Day! 😌", style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
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
                Text("Weight for ${DateFormat('d MMM').format(provider.selectedDate)}", style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
                Text(displayWeight, style: const TextStyle(fontSize: 14, color: Colors.white70)),
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
    final TextEditingController controller = TextEditingController(text: provider.weightForSelectedDate?.toString() ?? '');
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
            decoration: const InputDecoration(hintText: "e.g., 73.5", hintStyle: TextStyle(color: Colors.white54), suffixText: "kg"),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.white70))),
            TextButton(
              onPressed: () {
                final double? newWeight = double.tryParse(controller.text);
                if (newWeight != null) { provider.logUserWeight(newWeight); Navigator.pop(context); }
              },
              child: const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Widget _dateChip(BuildContext context, {required String day, required String date, required bool isActive, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.white.withOpacity(0.1),
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
}
