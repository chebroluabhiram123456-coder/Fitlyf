// lib/screens/weekly_plan_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/workout_provider.dart';
import '../models/workout_session.dart';

class WeeklyPlanScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WorkoutProvider>(context);
    final weeklyPlan = provider.weeklyPlan;
    // We need the master workout list to get names from IDs
    final masterWorkoutList = provider.masterWorkoutList;

    final daysOfWeek = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

    // Create a list of workout names for the dropdown dialog
    final workoutList = masterWorkoutList.map((workout) {
      return {'id': workout.id, 'name': workout.name};
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Weekly Plan'),
        backgroundColor: Colors.grey[900],
      ),
      body: ListView.builder(
        itemCount: daysOfWeek.length,
        itemBuilder: (context, index) {
          final day = daysOfWeek[index];
          final workoutId = weeklyPlan[index];
          final workoutName = workoutId == null
              ? 'Rest Day'
              : masterWorkoutList.firstWhere((w) => w.id == workoutId).name;

          return Card(
            color: Colors.grey[850],
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(day, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: Text(workoutName, style: TextStyle(color: Colors.grey[400])),
              trailing: Icon(Icons.edit, color: Colors.blueAccent),
              onTap: () {
                _showEditDialog(context, provider, index, workoutList);
              },
            ),
          );
        },
      ),
    );
  }

  void _showEditDialog(BuildContext context, WorkoutProvider provider, int dayIndex, List<Map<String, String>> workoutList) {
    String? currentSelection = provider.weeklyPlan[dayIndex];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[800],
          title: Text('Select Workout for ${['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'][dayIndex]}', style: TextStyle(color: Colors.white)),
          content: DropdownButton<String?>(
            value: currentSelection,
            isExpanded: true,
            dropdownColor: Colors.grey[700],
            style: TextStyle(color: Colors.white),
            onChanged: (String? newValue) {
                provider.updateWeeklyPlan(dayIndex, newValue);
                Navigator.of(context).pop();
            },
            items: [
              // Add the "Rest Day" option
              DropdownMenuItem<String?>(
                value: null,
                child: Text('Rest Day'),
              ),
              // Add the other workouts
              ...workoutList.map<DropdownMenuItem<String?>>((Map<String, String> workout) {
                return DropdownMenuItem<String?>(
                  value: workout['id'],
                  child: Text(workout['name']!),
                );
              }).toList(),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel', style: TextStyle(color: Colors.blueAccent)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

