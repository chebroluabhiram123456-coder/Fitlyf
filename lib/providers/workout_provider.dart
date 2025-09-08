import 'package:flutter/material.dart';
import 'package:fitlyf/models/workout_model.dart';
import 'package:fitlyf/models/exercise_model.dart';
import 'package:fitlyf/models/workout_status.dart';
import 'package:intl/intl.dart';
import 'dart:math';

// Data Models are included here to prevent any missing import errors
class WeightLog {
  final DateTime date;
  final double weight;
  WeightLog({ required this.date, required this.weight });
}

class LoggedWorkout {
  final DateTime date;
  final String workoutName;
  final WorkoutStatus status;
  LoggedWorkout({required this.date, required this.workoutName, required this.status});
}

// --- The Main Provider Class ---
class WorkoutProvider with ChangeNotifier {
  // --- USER & PROFILE DATA ---
  String _userName = "User";

  // --- MASTER DATA ---
  final List<Exercise> _allExercises = [
    Exercise(id: 'ex1', name: 'Push Ups', targetMuscle: 'Chest', sets: 3, reps: 12),
    Exercise(id: 'ex2', name: 'Squats', targetMuscle: 'Legs', sets: 4, reps: 10),
    Exercise(id: 'ex3', name: 'Bicep Curls', targetMuscle: 'Biceps', sets: 3, reps: 15),
    Exercise(id: 'ex4', name: 'Tricep Dips', targetMuscle: 'Triceps', sets: 3, reps: 15),
    Exercise(id: 'ex6', name: 'Pull Ups', targetMuscle: 'Back', sets: 3, reps: 8),
    Exercise(id: 'ex7', name: 'Shoulder Press', targetMuscle: 'Shoulders', sets: 3, reps: 12),
    Exercise(id: 'ex8', name: 'Crunches', targetMuscle: 'Abs', sets: 3, reps: 20),
    Exercise(id: 'ex9', name: 'Leg Press', targetMuscle: 'Legs', sets: 4, reps: 12),
    Exercise(id: 'ex10', name: 'Dumbbell Rows', targetMuscle: 'Back', sets: 3, reps: 12),
  ];
  
  // *** NEW: The list of all muscles the user can choose from ***
  final List<String> availableMuscleGroups = [
    'Chest', 'Back', 'Legs', 'Shoulders', 'Biceps', 'Triceps', 'Abs'
  ];

  // *** NEW: The weekly plan now stores a LIST of muscle strings for each day ***
  final Map<String, List<String>> _weeklyPlan = {
    'Monday': ['Chest', 'Triceps'],
    'Tuesday': ['Back', 'Biceps'],
    'Wednesday': ['Legs'],
    'Thursday': ['Shoulders', 'Abs'],
    'Friday': ['Chest', 'Back'],
    'Saturday': [], // Represents a Rest Day
    'Sunday': [], // Represents a Rest Day
  };
  
  // --- APP STATE & LOGS ---
  DateTime _selectedDate = DateTime.now();
  final List<WeightLog> _weightLogs = [
      WeightLog(date: DateTime.now().subtract(const Duration(days: 1)), weight: 75.5),
  ];
  final List<LoggedWorkout> _loggedWorkouts = [
    LoggedWorkout(date: DateTime.now().subtract(const Duration(days: 1)), workoutName: "Full Body Burn", status: WorkoutStatus.Completed),
  ];

  // =========== GETTERS ===========
  String get userName => _userName;
  List<Exercise> get allExercises => _allExercises;
  Map<String, List<String>> get weeklyPlan => _weeklyPlan;
  DateTime get selectedDate => _selectedDate;
  
  // *** NEW: Smarter logic to build a workout dynamically ***
  Workout? get workoutForSelectedDate {
    final dayKey = DateFormat('EEEE').format(_selectedDate);
    final plannedMuscles = _weeklyPlan[dayKey] ?? [];

    if (plannedMuscles.isEmpty) {
      return null; // This is a Rest Day
    }

    // Filter the master exercise list to get all exercises for the planned muscles
    final exercisesForToday = _allExercises
        .where((exercise) => plannedMuscles.contains(exercise.targetMuscle))
        .toList();

    // Create a new, temporary Workout object on the fly
    return Workout(
      id: 'custom_${dayKey.toLowerCase()}',
      name: plannedMuscles.join(' & '), // e.g., "Chest & Triceps"
      exercises: exercisesForToday,
    );
  }

  double? get weightForSelectedDate {
    try {
      return _weightLogs.firstWhere((log) => DateUtils.isSameDay(log.date, _selectedDate)).weight;
    } catch (e) { return null; }
  }

  // =========== METHODS ===========
  
  // *** NEW: Updated method to save a LIST of muscles for a day ***
  void updateWeeklyPlan(String day, List<String> muscles) {
    // If the list contains 'Rest', we clear it to signify a rest day.
    if (muscles.contains('Rest')) {
      _weeklyPlan[day] = [];
    } else {
      _weeklyPlan[day] = muscles;
    }
    notifyListeners();
  }

  void changeSelectedDate(DateTime newDate) {
    _selectedDate = newDate;
    notifyListeners();
  }

  void logUserWeight(double weight) {
    _weightLogs.removeWhere((log) => DateUtils.isSameDay(log.date, _selectedDate));
    _weightLogs.add(WeightLog(date: _selectedDate, weight: weight));
    notifyListeners();
  }
}
