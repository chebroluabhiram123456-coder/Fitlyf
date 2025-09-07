import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitlyf/providers/workout_provider.dart';
import 'package:fitlyf/models/workout_status.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('My Progress'),
        backgroundColor: Colors.grey[900]?.withOpacity(0.8),
        elevation: 0,
      ),
      body: Consumer<WorkoutProvider>(
        builder: (context, provider, child) {
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            children: [
              _buildWeightChartCard(provider),
              const SizedBox(height: 24),
              _buildCalendarCard(provider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildWeightChartCard(WorkoutProvider provider) {
    final weightHistory = provider.weightHistory..sort((a, b) => a.date.compareTo(b.date));
    
    return Card(
      color: Colors.grey[900],
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Weight History",
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            weightHistory.isEmpty
                ? const SizedBox(height: 150, child: Center(child: Text("No weight data logged.", style: TextStyle(color: Colors.white70))))
                : SizedBox(
                    height: 180,
                    child: LineChart(
                      _buildChartData(weightHistory),
                      duration: const Duration(milliseconds: 500),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarCard(WorkoutProvider provider) {
    return Card(
      color: Colors.grey[900],
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: TableCalendar(
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
          outsideTextStyle: const TextStyle(color: Colors.white30),
          todayDecoration: BoxDecoration(
            color: Colors.greenAccent.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          selectedDecoration: const BoxDecoration(
            color: Colors.greenAccent,
            shape: BoxShape.circle,
          ),
        ),
        headerStyle: const HeaderStyle(
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 18),
          formatButtonVisible: false,
          leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
          rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white),
        ),
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, date, events) {
            final status = provider.getWorkoutStatusForDate(date);
            if (status == WorkoutStatus.Completed) {
              return Positioned(
                bottom: 1,
                child: Container(
                  width: 6, height: 6,
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.greenAccent),
                ),
              );
            }
            if (status == WorkoutStatus.Skipped) {
              return Positioned(
                bottom: 1,
                child: Container(
                  width: 6, height: 6,
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.redAccent),
                ),
              );
            }
            return null;
          },
        ),
      ),
    );
  }

  LineChartData _buildChartData(List<WeightLog> history) {
    List<FlSpot> spots = history.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.weight);
    }).toList();

    return LineChartData(
      gridData: FlGridData(show: false),
      titlesData: FlTitlesData(show: false),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: Colors.greenAccent,
          barWidth: 4,
          isStrokeCapRound: true,
          dotData: FlDotData(show: true),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                Colors.greenAccent.withOpacity(0.3),
                Colors.greenAccent.withOpacity(0.0),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
    );
  }
}
