import 'package:flutter/material.dart';
import 'package:fitlyf/models/workout_model.dart';
import 'package:fitlyf/models/exercise_model.dart';
import 'package:fitlyf/models/workout_status.dart';
import 'package:intl/intl.dart'; // <-- THE MISSING IMPORT
import 'dart:math';

// --- Data Models are included here to prevent any missing import errors ---
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
  String? _profileImagePath;

  // --- MASTER DATA ---
  final List<Workout> _allWorkouts = [
    Workout(id: 'wk1', name: 'Legs & Shoulders', exercises: [
      Exercise(id: 'ex2', name: 'Squats', targetMuscle: 'Legs', sets: 4, reps: 10),
      Exercise(id: 'ex7', name: 'Shoulder Press', targetMuscle: 'Shoulders', sets: 3, reps: 12),
    ]),
    Workout(id: 'wk2', name: 'Chest & Triceps Crush', exercises: [
      Exercise(id: 'ex1', name: 'Push Ups', targetMuscle: 'Chest', sets: 3, reps: 12),
      Exercise(id: 'ex4', name: 'Tricep Dips', targetMuscle: 'Triceps', sets: 3, reps: 15),
    ]),
    Workout(id: 'wk3', name: 'Back & Biceps Builder', exercises: [
       Exercise(id: 'ex3', name: 'Bicep Curls', targetMuscle: 'Arms', sets: 3, reps: 15),
       Exercise(id: 'ex6', name: 'Pull Ups', targetMuscle: 'Back', sets: 3, reps: 8),
    ]),
  ];

  final Map<String, String?> _weeklyPlan = {
    'Mon': 'wk2', 'Tue': 'wk3', 'Wed': 'wk1', 'Thu': 'wk2', 
    'Fri': 'wk3','Sat': null,'Sun': null,
  };
  
  final List<Exercise> _allExercises = [
    Exercise(id: 'ex1', name: 'Push Ups', targetMuscle: 'Chest', sets: 3, reps: 12),
    Exercise(id: 'ex2', name: 'Squats', targetMuscle: 'Legs', sets: 4, reps: 10),
    Exercise(id: 'ex3', name: 'Bicep Curls', targetMuscle: 'Arms', sets: 3, reps: 15),
    Exercise(id: 'ex4', name: 'Tricep Dips', targetMuscle: 'Triceps', sets: 3, reps: 15),
    Exercise(id: 'ex6', name: 'Pull Ups', targetMuscle: 'Back', sets: 3, reps: 8),
    Exercise(id: 'ex7', name: 'Shoulder Press', targetMuscle: 'Shoulders', sets: 3, reps: 12),
  ];

  // --- APP STATE & LOGS ---
  final Set<String> inProgressExerciseIds = {};
  DateTime _selectedDate = DateTime.now();
  final List<WeightLog> _weightLogs = [
      WeightLog(date: DateTime.now().subtract(const Duration(days: 1)), weight: 75.5),
      WeightLog(date: DateTime.now().subtract(const Duration(days: 3)), weight: 76.0),
  ];
  final List<LoggedWorkout> _loggedWorkouts = [
    LoggedWorkout(date: DateTime.now().subtract(const Duration(days: 1)), workoutName: "Full Body Burn", status: WorkoutStatus.Completed),
    LoggedWorkout(date: DateTime.now().subtract(const Duration(days: 2)), workoutName: "Leg Day", status: WorkoutStatus.Skipped),
  ];

  // =========== GETTERS ===========
  String get userName => _userName;
  List<Workout> get allWorkouts => _allWorkouts;
  Map<String, String?> get weeklyPlan => _weeklyPlan;
  List<Exercise> get allExercises => _allExercises;
  List<LoggedWorkout> get workoutLog => _loggedWorkouts;
  List<WeightLog> get weightHistory => _weightLogs;
  DateTime get selectedDate => _selectedDate;

  Workout? get workoutForSelectedDate {
    final dayKey = DateFormat('E').format(_selectedDate);
    final workoutId = _weeklyPlan[dayKey];
    if (workoutId == null) return null;
    try {
      return _allWorkouts.firstWhere((workout) => workout.id == workoutId);
    } catch (e) {
      return null;
    }
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

  void logUserWeight(double weight) {
    _weightLogs.removeWhere((log) => DateUtils.isSameDay(log.date, _selectedDate));
    _weightLogs.add(WeightLog(date: _selectedDate, weight: weight));
    notifyListeners();
  }

  WorkoutStatus? getWorkoutStatusForDate(DateTime date) {
    try {
      return _loggedWorkouts.firstWhere((log) => DateUtils.isSameDay(log.date, date)).status;
    } catch (e) { return null; }
  }

  void deleteLoggedWorkout(DateTime date) {
    _loggedWorkouts.removeWhere((log) => DateUtils.isSameDay(log.date, date));
    notifyListeners();
  }

  void updateWeeklyPlan(String day, String? workoutId) {
    _weeklyPlan[day] = workoutId;
    notifyListeners();
  }
  
  // *** RESTORED METHOD 1 ***
  void addCustomExercise(Exercise newExercise) {
    _allExercises.add(newExercise);
    notifyListeners();
  }

  // *** RESTORED METHOD 2 ***
  void updateExercise(Exercise updatedExercise) {
    final index = _allExercises.indexWhere((ex) => ex.id == updatedExercise.id);
    if (index != -1) {
      _allExercises[index] = updatedExercise;
      notifyListeners();
    }
  }
  
  void toggleExerciseStatus(String exerciseId) {
    if (inProgressExerciseIds.contains(exerciseId)) { inProgressExerciseIds.remove(exerciseId); } else { inProgressExerciseIds.add(exerciseId); }
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
