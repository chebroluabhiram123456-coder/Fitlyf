import 'package:flutter/material.dart';
import 'package:fitlyf/models/workout_model.dart';
import 'package:fitlyf/models/exercise_model.dart';
import 'package:fitlyf/models/workout_status.dart';
import 'dart:math';
import 'package:intl/intl.dart'; // Needed for DateFormat

// *** BLUEPRINT 1: The WeightLog class is now defined HERE ***
class WeightLog {
  final DateTime date;
  final double weight;
  WeightLog({ required this.date, required this.weight });
}

// *** BLUEPRINT 2: The LoggedWorkout class is also here for simplicity ***
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

  // --- MASTER DATA (Our App's "Database") ---
  
  // *** CHANGE 1: A MASTER LIST OF ALL WORKOUTS ***
  // This list holds all possible workouts the user can choose from.
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

  // *** CHANGE 2: THE WEEKLY PLAN NOW STORES WORKOUT IDs ***
  // This creates a direct link between a day and a specific workout from the list above.
  final Map<String, String?> _weeklyPlan = {
    'Mon': 'wk1', // Monday -> Chest & Triceps Crush
    'Tue': 'wk3', // Tuesday -> Back & Biceps Builder
    'Wed': 'wk2', // Wednesday -> Leg Day Annihilation
    'Thu': 'wk1', 
    'Fri': 'wk3',
    'Sat': null, // Rest Day
    'Sun': null, // Rest Day
  };
  
  final List<String> _availableMuscleGroups = [
    'Full Body', 'Chest', 'Back', 'Legs', 'Shoulders', 'Biceps', 'Triceps', 'Abs', 'Rest'
  ];

  final List<Exercise> _allExercises = [
    Exercise(id: 'ex1', name: 'Push Ups', targetMuscle: 'Chest', sets: 3, reps: 12),
    Exercise(id: 'ex2', name: 'Squats', targetMuscle: 'Legs', sets: 4, reps: 10),
    Exercise(id: 'ex3', name: 'Bicep Curls', targetMuscle: 'Arms', sets: 3, reps: 15),
    Exercise(id: 'ex4', name: 'Tricep Dips', targetMuscle: 'Triceps', sets: 3, reps: 15),
    Exercise(id: 'ex5', name: 'Lunges', targetMuscle: 'Legs', sets: 3, reps: 12),
    Exercise(id: 'ex6', name: 'Pull Ups', targetMuscle: 'Back', sets: 3, reps: 8),
  ];

  // --- APP STATE ---
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
  String? get profileImagePath => _profileImagePath;
  Map<String, String?> get weeklyPlan => _weeklyPlan; // Now returns Map<String, String?>
  List<Workout> get allWorkouts => _allWorkouts; // Expose the master workout list
  List<String> get availableMuscleGroups => _availableMuscleGroups;
  List<Exercise> get allExercises => _allExercises;
  List<LoggedWorkout> get workoutLog => _loggedWorkouts;
  List<WeightLog> get weightHistory => _weightLogs;
  DateTime get selectedDate => _selectedDate;

  // *** CHANGE 3: THE DYNAMIC GETTER FOR THE HOME SCREEN ***
  // This is the core of the new sync logic.
  Workout? get workoutForSelectedDate {
    // 1. Get the day of the week (e.g., 'Mon', 'Tue') from the selected date.
    final dayKey = DateFormat('E').format(_selectedDate);
    
    // 2. Look up the workout ID for that day in our plan.
    final workoutId = _weeklyPlan[dayKey];
    
    if (workoutId == null) {
      return null; // It's a rest day.
    }
    
    // 3. Find the full workout object from our master list.
    try {
      return _allWorkouts.firstWhere((workout) => workout.id == workoutId);
    } catch (e) {
      return null; // Safety check in case the ID is invalid.
    }
  }

  double? get weightForSelectedDate {
    try {
      return _weightLogs.firstWhere((log) => DateUtils.isSameDay(log.date, _selectedDate)).weight;
    } catch (e) { return null; }
  }

  // =========== METHODS ===========

  // *** CHANGE 4: UPDATED METHOD FOR THE WEEKLY PLAN SCREEN ***
  // This now accepts a day and a workout ID to update the plan.
  void updateWeeklyPlan(String day, String? workoutId) {
    _weeklyPlan[day] = workoutId;
    notifyListeners();
  }

  void changeSelectedDate(DateTime newDate) {
    _selectedDate = newDate;
    notifyListeners();
  }
  
  // ... all other methods remain the same ...
  void updateUserName(String newName) { _userName = newName; notifyListeners(); }
  void updateProfilePicture(String imagePath) { _profileImagePath = imagePath; notifyListeners(); }
  void addCustomExercise(Exercise newExercise) { _allExercises.add(newExercise); notifyListeners(); }
  void updateExercise(Exercise updatedExercise) {
    final index = _allExercises.indexWhere((ex) => ex.id == updatedExercise.id);
    if (index != -1) { _allExercises[index] = updatedExercise; notifyListeners(); }
  }
  void deleteExercise(String exerciseId) { _allExercises.removeWhere((ex) => ex.id == exerciseId); notifyListeners(); }
  void deleteLoggedWorkout(DateTime date) { _loggedWorkouts.removeWhere((log) => DateUtils.isSameDay(log.date, date)); notifyListeners(); }
  WorkoutStatus? getWorkoutStatusForDate(DateTime date) {
    try { return _loggedWorkouts.firstWhere((log) => DateUtils.isSameDay(log.date, date)).status; } catch (e) { return null; }
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
  void logUserWeight(double weight) {
    _weightLogs.removeWhere((log) => DateUtils.isSameDay(log.date, _selectedDate));
    _weightLogs.add(WeightLog(date: _selectedDate, weight: weight));
    notifyListeners();
  }
}
