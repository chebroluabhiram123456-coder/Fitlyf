import 'package:flutter/material.dart';
import 'package:fitlyf/models/workout_model.dart';
import 'package:fitlyf/models/exercise_model.dart';
import 'package:fitlyf/models/workout_status.dart';
import 'package:intl/intl.dart';
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
       Exercise(id: 'ex3', name: 'Bicep Curls', targetMuscle: 'Biceps', sets: 3, reps: 15),
       Exercise(id: 'ex6', name: 'Pull Ups', targetMuscle: 'Back', sets: 3, reps: 8),
    ]),
  ];

  final Map<String, List<String>> _weeklyPlan = {
    'Monday': ['Chest', 'Triceps'], 'Tuesday': ['Back', 'Biceps'], 'Wednesday': ['Legs'],
    'Thursday': ['Shoulders', 'Abs'],'Friday': ['Chest', 'Back'],'Saturday': [],'Sunday': [],
  };
  
  final List<String> availableMuscleGroups = [
    'Chest', 'Back', 'Legs', 'Shoulders', 'Biceps', 'Triceps', 'Abs'
  ];
  
  final List<Exercise> _allExercises = [
    Exercise(id: 'ex1', name: 'Push Ups', targetMuscle: 'Chest', sets: 3, reps: 12),
    Exercise(id: 'ex2', name: 'Squats', targetMuscle: 'Legs', sets: 4, reps: 10),
    Exercise(id: 'ex3', name: 'Bicep Curls', targetMuscle: 'Biceps', sets: 3, reps: 15),
    Exercise(id: 'ex4', name: 'Tricep Dips', targetMuscle: 'Triceps', sets: 3, reps: 15),
    Exercise(id: 'ex6', name: 'Pull Ups', targetMuscle: 'Back', sets: 3, reps: 8),
    Exercise(id: 'ex7', name: 'Shoulder Press', targetMuscle: 'Shoulders', sets: 3, reps: 12),
    Exercise(id: 'ex8', name: 'Crunches', targetMuscle: 'Abs', sets: 3, reps: 20),
  ];

  // --- APP STATE & LOGS ---
  DateTime _selectedDate = DateTime.now();
  final List<WeightLog> _weightLogs = [
      WeightLog(date: DateTime.now().subtract(const Duration(days: 1)), weight: 75.5),
      WeightLog(date: DateTime.now().subtract(const Duration(days: 3)), weight: 76.0),
  ];
  final List<LoggedWorkout> _loggedWorkouts = [
    LoggedWorkout(date: DateTime.now().subtract(const Duration(days: 1)), workoutName: "Full Body Burn", status: WorkoutStatus.Completed),
    LoggedWorkout(date: DateTime.now().subtract(const Duration(days: 2)), workoutName: "Leg Day", status: WorkoutStatus.Skipped),
  ];

  // =========== GETTERS (These were all missing) ===========
  String get userName => _userName;
  String? get profileImagePath => _profileImagePath;
  List<Workout> get allWorkouts => _allWorkouts;
  Map<String, List<String>> get weeklyPlan => _weeklyPlan;
  List<Exercise> get allExercises => _allExercises;
  List<LoggedWorkout> get workoutLog => _loggedWorkouts;
  List<WeightLog> get weightHistory => _weightLogs;
  DateTime get selectedDate => _selectedDate;

  Workout? get workoutForSelectedDate {
    final dayKey = DateFormat('EEEE').format(_selectedDate);
    final plannedMuscles = _weeklyPlan[dayKey] ?? [];
    if (plannedMuscles.isEmpty) return null;
    final exercisesForToday = _allExercises
        .where((exercise) => plannedMuscles.contains(exercise.targetMuscle))
        .toList();
    return Workout(
      id: 'custom_${dayKey.toLowerCase()}',
      name: plannedMuscles.join(' & '),
      exercises: exercisesForToday,
    );
  }

  double? get weightForSelectedDate {
    try {
      return _weightLogs.firstWhere((log) => DateUtils.isSameDay(log.date, _selectedDate)).weight;
    } catch (e) { return null; }
  }

  // =========== METHODS (These were all missing) ===========
  void updateUserName(String newName) {
    _userName = newName;
    notifyListeners();
  }

  void updateProfilePicture(String imagePath) {
    _profileImagePath = imagePath;
    notifyListeners();
  }

  void deleteExercise(String exerciseId) {
    _allExercises.removeWhere((ex) => ex.id == exerciseId);
    notifyListeners();
  }

  void deleteLoggedWorkout(DateTime date) {
    _loggedWorkouts.removeWhere((log) => DateUtils.isSameDay(log.date, date));
    notifyListeners();
  }
  
  WorkoutStatus? getWorkoutStatusForDate(DateTime date) {
    try {
      return _loggedWorkouts.firstWhere((log) => DateUtils.isSameDay(log.date, date)).status;
    } catch (e) { return null; }
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

  void updateWeeklyPlan(String day, List<String> muscles) {
    if (muscles.contains('Rest')) {
      _weeklyPlan[day] = [];
    } else {
      _weeklyPlan[day] = muscles;
    }
    notifyListeners();
  }
}
