import 'package:flutter/material.dart';
import 'package:fitlyf/models/workout_model.dart';
import 'package:fitlyf/models/exercise_model.dart';
import 'package:fitlyf/models/weight_log_model.dart';
import 'package:fitlyf/models/workout_status.dart';
import 'dart:math';

class LoggedWorkout {
  final DateTime date;
  final String workoutName;
  final WorkoutStatus status;
  LoggedWorkout({required this.date, required this.workoutName, required this.status});
}

class WorkoutProvider with ChangeNotifier {
  // --- USER & PROFILE DATA ---
  String _userName = "User";
  String? _profileImagePath;

  // --- WEEKLY PLAN DATA ---
  final Map<String, List<String>> _weeklyPlan = {
    'Mon': ['Chest', 'Triceps'], 'Tue': ['Back', 'Biceps'], 'Wed': ['Legs'],
    'Thu': ['Shoulders'],'Fri': ['Full Body'],'Sat': ['Rest'],'Sun': ['Rest'],
  };
  
  // *** THIS LIST WAS MISSING ***
  final List<String> _availableMuscleGroups = [
    'Full Body', 'Chest', 'Back', 'Legs', 'Shoulders', 'Biceps', 'Triceps', 'Abs', 'Rest'
  ];

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
      WeightLog(date: DateTime.now().subtract(const Duration(days: 1)), weight: 75.5),
      WeightLog(date: DateTime.now().subtract(const Duration(days: 3)), weight: 76.0),
  ];
  final List<LoggedWorkout> _loggedWorkouts = [
    LoggedWorkout(date: DateTime.now().subtract(const Duration(days: 1)), workoutName: "Full Body Burn", status: WorkoutStatus.Completed),
    LoggedWorkout(date: DateTime.now().subtract(const Duration(days: 2)), workoutName: "Leg Day", status: WorkoutStatus.Skipped),
  ];

  // =========== GETTERS ===========
  String get userName => _userName;
  String? get profileImagePath => _profileImagePath;
  Map<String, List<String>> get weeklyPlan => _weeklyPlan;
  List<String> get availableMuscleGroups => _availableMuscleGroups;
  List<Exercise> get allExercises => _allExercises;
  List<LoggedWorkout> get workoutLog => _loggedWorkouts;
  List<WeightLog> get weightHistory => _weightLogs;
  
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

  // =========== METHODS ===========
  void updateUserName(String newName) {
    _userName = newName;
    notifyListeners();
  }
  
  void updateProfilePicture(String imagePath) {
    _profileImagePath = imagePath;
    notifyListeners();
  }

  void updateWeeklyPlan(String day, List<String> muscles) {
    _weeklyPlan[day] = muscles;
    notifyListeners();
  }

  void addCustomExercise(Exercise newExercise) {
    _allExercises.add(newExercise);
    notifyListeners();
  }

  void updateExercise(Exercise updatedExercise) {
    final index = _allExercises.indexWhere((ex) => ex.id == updatedExercise.id);
    if (index != -1) {
      _allExercises[index] = updatedExercise;
      notifyListeners();
    }
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
