import 'package:flutter/material.dart';
import 'package:fitlyf/models/workout_model.dart';
import 'package:fitlyf/models/exercise_model.dart';
import 'package:fitlyf/models/workout_status.dart';
import 'dart:math';
import 'package:intl/intl.dart';

// Blueprint for a single weight log entry
class WeightLog {
  final DateTime date;
  final double weight;
  WeightLog({ required this.date, required this.weight });
}

// Blueprint for a workout in the history log
class LoggedWorkout {
  final DateTime date;
  final String workoutName;
  final WorkoutStatus status;
  LoggedWorkout({required this.date, required this.workoutName, required this.status});
}

// The Main Provider Class - The "Brain" of the App
class WorkoutProvider with ChangeNotifier {
  // --- MASTER DATA (Our App's "Database") ---
  final List<Workout> _allWorkouts = [
    Workout(id: 'wk1', name: 'Chest & Triceps Crush', exercises: [
      Exercise(id: 'ex1', name: 'Push Ups', targetMuscle: 'Chest', sets: 3, reps: 12),
      Exercise(id: 'ex4', name: 'Tricep Dips', targetMuscle: 'Triceps', sets: 3, reps: 15),
    ]),
    Workout(id: 'wk2', name: 'Leg Day Annihilation', exercises: [
      Exercise(id: 'ex2', name: 'Squats', targetMuscle: 'Legs', sets: 4, reps: 10),
      Exercise(id: 'ex5', name: 'Lunges', targetMuscle: 'Legs', sets: 3, reps: 12),
    ]),
    Workout(id: 'wk3', name: 'Back & Biceps Builder', exercises: [
       Exercise(id: 'ex3', name: 'Bicep Curls', targetMuscle: 'Arms', sets: 3, reps: 15),
       Exercise(id: 'ex6', name: 'Pull Ups', targetMuscle: 'Back', sets: 3, reps: 8),
    ]),
  ];

  final Map<String, String?> _weeklyPlan = {
    'Mon': 'wk1', 'Tue': 'wk3', 'Wed': 'wk2', 'Thu': 'wk1', 
    'Fri': 'wk3', 'Sat': null, 'Sun': null,
  };
  
  final List<Exercise> _allExercises = [
    Exercise(id: 'ex1', name: 'Push Ups', targetMuscle: 'Chest', sets: 3, reps: 12),
    Exercise(id: 'ex2', name: 'Squats', targetMuscle: 'Legs', sets: 4, reps: 10),
    Exercise(id: 'ex3', name: 'Bicep Curls', targetMuscle: 'Arms', sets: 3, reps: 15),
    Exercise(id: 'ex4', name: 'Tricep Dips', targetMuscle: 'Triceps', sets: 3, reps: 15),
    Exercise(id: 'ex5', name: 'Lunges', targetMuscle: 'Legs', sets: 3, reps: 12),
    Exercise(id: 'ex6', name: 'Pull Ups', targetMuscle: 'Back', sets: 3, reps: 8),
  ];

  // --- APP STATE ---
  String _userName = "User";
  DateTime _selectedDate = DateTime.now();
  final Set<String> inProgressExerciseIds = {};
  final List<WeightLog> _weightLogs = [
      WeightLog(date: DateTime.now().subtract(const Duration(days: 1)), weight: 75.5),
      WeightLog(date: DateTime.now().subtract(const Duration(days: 3)), weight: 76.0),
  ];
  final List<LoggedWorkout> _loggedWorkouts = [
    LoggedWorkout(date: DateTime.now().subtract(const Duration(days: 1)), workoutName: "Full Body Burn", status: WorkoutStatus.Completed),
  ];

  // =========== GETTERS ===========
  String get userName => _userName;
  List<Workout> get allWorkouts => _allWorkouts;
  Map<String, String?> get weeklyPlan => _weeklyPlan;
  List<Exercise> get allExercises => _allExercises;
  DateTime get selectedDate => _selectedDate;
  
  Workout? get workoutForSelectedDate {
    final dayKey = DateFormat('E').format(_selectedDate);
    final workoutId = _weeklyPlan[dayKey];
    if (workoutId == null) return null;
    try {
      return _allWorkouts.firstWhere((w) => w.id == workoutId);
    } catch (e) { return null; }
  }
  
  double? get weightForSelectedDate {
    try {
      return _weightLogs.firstWhere((log) => DateUtils.isSameDay(log.date, _selectedDate)).weight;
    } catch (e) { return null; }
  }

  // =========== METHODS ===========
  void changeSelectedDate(DateTime newDate) {
    _selectedDate = newDate;
    notifyListeners();
  }
  
  void updateWeeklyPlan(String day, String? workoutId) {
    _weeklyPlan[day] = workoutId;
    notifyListeners();
  }

  void logUserWeight(double weight) {
    _weightLogs.removeWhere((log) => DateUtils.isSameDay(log.date, _selectedDate));
    _weightLogs.add(WeightLog(date: _selectedDate, weight: weight));
    notifyListeners();
  }
  
  void quickLogWorkout(Workout workout) {
    final allExerciseIds = workout.exercises.map((e) => e.id).toSet();
    inProgressExerciseIds.addAll(allExerciseIds);
    _loggedWorkouts.removeWhere((log) => DateUtils.isSameDay(log.date, _selectedDate));
    _loggedWorkouts.add(LoggedWorkout(date: _selectedDate, workoutName: workout.name, status: WorkoutStatus.Completed));
    notifyListeners();
  }
}
