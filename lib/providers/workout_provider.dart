import 'package:flutter/material.dart';
import 'package:fitlyf/models/workout_model.dart';
import 'package:fitlyf/models/exercise_model.dart';
import 'package:fitlyf/models/weight_log_model.dart';
import 'package:fitlyf/models/workout_status.dart';

// A simple model for our logged workout history
class LoggedWorkout {
  final DateTime date;
  final String workoutName;
  final WorkoutStatus status;
  LoggedWorkout({required this.date, required this.workoutName, required this.status});
}

class WorkoutProvider with ChangeNotifier {
  // --- USER & SETTINGS DATA ---
  String _userName = "User";
  
  // --- EXERCISE LIBRARY DATA ---
  final List<Exercise> _allExercises = [
    Exercise(id: 'ex1', name: 'Push Ups', targetMuscle: 'Chest', sets: 3, reps: 12),
    Exercise(id: 'ex2', name: 'Squats', targetMuscle: 'Legs', sets: 4, reps: 10),
    Exercise(id: 'ex3', name: 'Bicep Curls', targetMuscle: 'Arms', sets: 3, reps: 15),
  ];

  // --- WORKOUT & PROGRESS DATA ---
  final Set<String> inProgressExerciseIds = {};
  Workout? _selectedWorkout;
  DateTime _selectedDate = DateTime.now();

  // --- HISTORY & LOGGING DATA ---
  final List<WeightLog> _weightLogs = [
      // Placeholder data so your history isn't empty
      WeightLog(date: DateTime.now().subtract(const Duration(days: 1)), weight: 75.5),
      WeightLog(date: DateTime.now().subtract(const Duration(days: 3)), weight: 76.0),
      WeightLog(date: DateTime.now().subtract(const Duration(days: 5)), weight: 75.8),
  ];
  final List<LoggedWorkout> _loggedWorkouts = [
    LoggedWorkout(date: DateTime.now().subtract(const Duration(days: 1)), workoutName: "Full Body Burn", status: WorkoutStatus.Completed),
    LoggedWorkout(date: DateTime.now().subtract(const Duration(days: 2)), workoutName: "Leg Day", status: WorkoutStatus.Skipped),
    LoggedWorkout(date: DateTime.now().subtract(const Duration(days: 3)), workoutName: "Upper Body Blast", status: WorkoutStatus.Completed),
  ];


  // =========== GETTERS (Fixing the naming mismatches) ===========
  String get userName => _userName;
  List<Exercise> get allExercises => _allExercises;
  List<LoggedWorkout> get workoutLog => _loggedWorkouts; // Corrected name for workout history
  List<WeightLog> get weightHistory => _weightLogs; // Corrected name for weight history
  
  Workout? get selectedWorkout => _selectedWorkout;
  DateTime get selectedDate => _selectedDate;
  int get weeklyStreakCount => 3;
  int get weeklyWorkoutDaysCount => 5;
  String get streakMessage => "You're on a roll!";
  double? get weightForSelectedDate {
    try {
      return _weightLogs.firstWhere((log) => DateUtils.isSameDay(log.date, _selectedDate)).weight;
    } catch (e) { return null; }
  }


  // =========== METHODS (Adding the missing functions) ===========

  // --- Settings ---
  void updateUserName(String newName) {
    _userName = newName;
    notifyListeners();
  }

  // --- Exercise Library ---
  void deleteExercise(String exerciseId) {
    _allExercises.removeWhere((ex) => ex.id == exerciseId);
    notifyListeners();
  }
  
  // *** NEW METHOD for AddExerciseScreen ***
  void addCustomExercise(Exercise newExercise) {
    _allExercises.add(newExercise);
    notifyListeners();
  }
  
  // --- Workout History ---
  void deleteLoggedWorkout(DateTime date) {
    _loggedWorkouts.removeWhere((log) => DateUtils.isSameDay(log.date, date));
    notifyListeners();
  }
  
  // *** NEW METHOD for WorkoutHistoryScreen ***
  WorkoutStatus? getWorkoutStatusForDate(DateTime date) {
    try {
      return _loggedWorkouts.firstWhere((log) => DateUtils.isSameDay(log.date, date)).status;
    } catch (e) {
      return null; // Return null if no log is found for that date
    }
  }

  // --- Daily Workout Progress ---
  void toggleExerciseStatus(String exerciseId) {
    if (inProgressExerciseIds.contains(exerciseId)) {
      inProgressExerciseIds.remove(exerciseId);
    } else {
      inProgressExerciseIds.add(exerciseId);
    }
    notifyListeners();
  }

  void quickLogWorkout(Workout workout) {
    final allExerciseIds = workout.exercises.map((e) => e.id).toSet();
    inProgressExerciseIds.addAll(allExerciseIds);
    _loggedWorkouts.removeWhere((log) => DateUtils.isSameDay(log.date, _selectedDate));
    _loggedWorkouts.add(LoggedWorkout(date: _selectedDate, workoutName: workout.name, status: WorkoutStatus.Completed));
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
