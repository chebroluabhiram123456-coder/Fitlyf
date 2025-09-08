import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:fitlyf/providers/workout_provider.dart';
import 'package:fitlyf/models/workout_model.dart';
import 'package:fitlyf/widgets/frosted_glass_card.dart';
import 'package:intl/intl.dart';

class WorkoutHistoryScreen extends StatefulWidget {
  const WorkoutHistoryScreen({Key? key}) : super(key: key);

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
        final loggedWorkouts = provider.workoutLog;
        final selectedDayLog = loggedWorkouts[DateUtils.dateOnly(_selectedDay!)];

        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text('Workout History'),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: Column(
            children: [
              _buildCalendar(provider),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                child: Divider(color: Colors.white24),
              ),
              Expanded(
                child: selectedDayLog != null
                    ? _buildWorkoutDetails(context, provider, selectedDayLog)
                    : _buildNoWorkoutMessage(),
              ),
            ],
          ),
        );
      },
    );
  }

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

  Widget _buildWorkoutDetails(BuildContext context, WorkoutProvider provider, Workout workout) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          FrostedGlassCard(
            child: ExpansionTile(
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

  Widget _buildNoWorkoutMessage() {
    return const Center(
      child: Text(
        'No workout was logged for this day.',
        style: TextStyle(color: Colors.white70, fontSize: 16),
      ),
    );
  }

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
