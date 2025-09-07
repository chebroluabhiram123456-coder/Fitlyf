import 'package:flutter/material.dart';
import 'package:fitlyf/models/workout_model.dart';
import 'package:fitlyf/models/weight_log_model.dart'; // Assuming you have this model

class WorkoutProvider with ChangeNotifier {
  // --- EXISTING PROPERTIES ---
  Workout? _selectedWorkout;
  DateTime _selectedDate = DateTime.now();
  String _userName = "User";
  final List<WeightLog> _weightLogs = [];
  
  // This Set will now be our single source of truth for completed exercises
  final Set<String> inProgressExerciseIds = {};

  // --- GETTERS ---
  Workout? get selectedWorkout => _selectedWorkout;
  DateTime get selectedDate => _selectedDate;
  String get userName => _userName;
  int get weeklyStreakCount => 3; // Placeholder
  int get weeklyWorkoutDaysCount => 5; // Placeholder
  String get streakMessage => "You're on a roll!"; // Placeholder
  
  double? get weightForSelectedDate {
    try {
      return _weightLogs.firstWhere((log) => DateUtils.isSameDay(log.date, _selectedDate)).weight;
    } catch (e) {
      return null;
    }
  }

  // --- METHODS ---
  void changeSelectedDate(DateTime newDate) {
    _selectedDate = newDate;
    // In a real app, you'd fetch the workout for the new date here
    // For example: _selectedWorkout = fetchWorkoutFor(newDate);
    notifyListeners();
  }

  void logUserWeight(double weight) {
    _weightLogs.removeWhere((log) => DateUtils.isSameDay(log.date, _selectedDate));
    _weightLogs.add(WeightLog(date: _selectedDate, weight: weight));
    notifyListeners();
  }
  
  // *** NEW METHOD 1: For the checkboxes ***
  // Toggles the completion status of a single exercise.
  void toggleExerciseStatus(String exerciseId) {
    if (inProgressExerciseIds.contains(exerciseId)) {
      inProgressExerciseIds.remove(exerciseId);
    } else {
      inProgressExerciseIds.add(exerciseId);
    }
    notifyListeners(); // This will trigger the UI to update
  }
  
  // *** NEW METHOD 2: For the "Quick Log" button ***
  // Marks all exercises in a given workout as complete.
  void quickLogWorkout(Workout workout) {
    final allExerciseIds = workout.exercises.map((e) => e.id).toSet();
    inProgressExerciseIds.addAll(allExerciseIds);
    notifyListeners(); // This will trigger the UI to update
  }
}
