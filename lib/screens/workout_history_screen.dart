import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:fitlyf/providers/workout_provider.dart';
import 'package:fitlyf/models/workout_model.dart';
import 'package:fitlyf/models/workout_status.dart'; // Import for WorkoutStatus enum
import 'package:fitlyf/widgets/frosted_glass_card.dart';
import 'package:intl/intl.dart';

class WorkoutHistoryScreen extends StatefulWidget {
  const WorkoutHistoryScreen({super.key});

  @override
  _WorkoutHistoryScreenState createState() => _WorkoutHistoryScreenState();
}

class _WorkoutHistoryScreenState extends State<WorkoutHistoryScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutProvider>(
      builder: (context, provider, child) {
        // *** FIX 1: Find the logged workout for the selected day from the LIST ***
        LoggedWorkout? selectedDayLog;
        try {
          selectedDayLog = provider.workoutLog.firstWhere(
            (log) => DateUtils.isSameDay(log.date, _selectedDay),
          );
        } catch (e) {
          selectedDayLog = null; // No log found for this day
        }
        
        // *** FIX 2: Find the full Workout object from the master list ***
        // This allows us to display the list of exercises.
        Workout? fullWorkoutDetails;
        if (selectedDayLog != null) {
          try {
            fullWorkoutDetails = provider.allWorkouts.firstWhere(
              (w) => w.name == selectedDayLog!.workoutName,
            );
          } catch (e) {
            fullWorkoutDetails = null; // Workout might have been deleted
          }
        }

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
              title: const Text('Workout History'),
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
            body: Column(
              children: [
                // Your original, beautiful calendar
                _buildCalendar(provider),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  child: Divider(color: Colors.white24),
                ),
                Expanded(
                  // Your original logic for showing details or a message
                  child: fullWorkoutDetails != null
                      ? _buildWorkoutDetails(context, provider, fullWorkoutDetails)
                      : _buildNoWorkoutMessage(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Your original _buildCalendar method - perfect as it was.
  Widget _buildCalendar(WorkoutProvider provider) {
    return TableCalendar(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.now().add(const Duration(days: 365)),
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
      },
      calendarStyle: CalendarStyle(
        defaultTextStyle: const TextStyle(color: Colors.white),
        weekendTextStyle: const TextStyle(color: Colors.white70),
        todayDecoration: BoxDecoration(
          color: Colors.white.withOpacity(0.3),
          shape: BoxShape.circle,
        ),
        selectedDecoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        selectedTextStyle: const TextStyle(color: Color(0xFF2D1458)),
        outsideTextStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
      ),
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 18.0),
        leftChevronIcon: const Icon(Icons.chevron_left, color: Colors.white),
        rightChevronIcon: const Icon(Icons.chevron_right, color: Colors.white),
      ),
      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, date, events) {
          final status = provider.getWorkoutStatusForDate(date);
          if (status == WorkoutStatus.Completed) {
            return Positioned(
              bottom: 1,
              child: Container(
                height: 7, width: 7,
                decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.greenAccent),
              ),
            );
          } else if (status == WorkoutStatus.Skipped) {
            return Positioned(
              bottom: 1,
              child: Container(
                height: 7, width: 7,
                decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.redAccent),
              ),
            );
          }
          return null;
        },
      ),
    );
  }

  // Your original _buildWorkoutDetails method - perfect as it was.
  Widget _buildWorkoutDetails(BuildContext context, WorkoutProvider provider, Workout workout) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          FrostedGlassCard(
            child: ExpansionTile(
              // The ExpansionTile is initially expanded by default for a better user experience
              initiallyExpanded: true,
              iconColor: Colors.white,
              collapsedIconColor: Colors.white70,
              title: Text(
                '${DateFormat('d MMMM yyyy').format(_selectedDay!)} - ${workout.name}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
              ),
              children: workout.exercises.map((ex) => ListTile(
                leading: const Icon(Icons.fitness_center, color: Colors.white70, size: 20),
                title: Text(ex.name, style: const TextStyle(color: Colors.white)),
                subtitle: Text('${ex.sets} sets x ${ex.reps} reps', style: const TextStyle(color: Colors.white70)),
              )).toList(),
            ),
          ),
          const SizedBox(height: 20),
          TextButton.icon(
            onPressed: () => _showDeleteConfirmation(context, provider, _selectedDay!),
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            label: const Text('Delete this Log Entry', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  // Your original _buildNoWorkoutMessage method - perfect as it was.
  Widget _buildNoWorkoutMessage() {
    return const Center(
      child: Text(
        'No workout was logged for this day.',
        style: TextStyle(color: Colors.white70, fontSize: 16),
      ),
    );
  }

  // Your original _showDeleteConfirmation method - perfect as it was.
  void _showDeleteConfirmation(BuildContext context, WorkoutProvider provider, DateTime date) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF3E246E),
        title: const Text('Confirm Deletion', style: TextStyle(color: Colors.white)),
        content: Text('Are you sure you want to delete the log for ${DateFormat('d MMM').format(date)}?', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
            onPressed: () {
              provider.deleteLoggedWorkout(date);
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }
}
