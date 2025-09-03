import 'package:flutter/material.dart';
import 'package:fitflow/models/exercise_model.dart';
import 'package:fitflow/models/workout_session.dart';

class WorkoutProvider with ChangeNotifier {
  // --- USER PROFILE DATA ---
  double _userWeight = 70.0; // in kg
  String _userHeight = "5'10\""; // in feet and inches
  final Map<DateTime, double> _weightHistory = {
    DateTime(2025, 8, 1): 72.0,
    DateTime(2025, 8, 8): 71.5,
    DateTime(2025, 8, 15): 71.0,
    DateTime(2025, 9, 1): 70.0,
  };

  double get userWeight => _userWeight;
  String get userHeight => _userHeight;
  Map<DateTime, double> get weightHistory => _weightHistory;

  void updateUserWeight(double newWeight) {
    _userWeight = newWeight;
    _weightHistory[DateTime.now()] = newWeight;
    notifyListeners();
  }

  // --- WORKOUT DATA ---
  List<WorkoutSession> _workoutHistory = [];
  List<Exercise> _customExercises = [];

  List<WorkoutSession> get workoutHistory => _workoutHistory;
  List<Exercise> get customExercises => _customExercises;
  
  WorkoutProvider() {
    // Load mock data for demonstration
    _loadInitialData();
  }

  WorkoutSession getTodaysWorkout() {
    DateTime today = DateUtils.dateOnly(DateTime.now());
    return _workoutHistory.firstWhere(
      (session) => DateUtils.isSameDay(session.date, today),
      orElse: () {
        // Create a default workout if none exists for today
        final defaultWorkout = WorkoutSession(
          date: today,
          muscleTarget: 'Rest Day',
          exercises: [],
        );
        _workoutHistory.add(defaultWorkout);
        return defaultWorkout;
      },
    );
  }

  void toggleExerciseCompletion(String exerciseId) {
    final todayWorkout = getTodaysWorkout();
    final exercise = todayWorkout.exercises.firstWhere((ex) => ex.id == exerciseId);
    exercise.isCompleted = !exercise.isCompleted;
    notifyListeners();
  }
  
  void updateTodaysMuscleTarget(String newTarget) {
     final todayWorkout = getTodaysWorkout();
     todayWorkout.muscleTarget = newTarget;
     // You might want to update the exercise list based on the new target
     // For now, we just change the title
     notifyListeners();
  }
  
  void addCustomExercise(Exercise exercise) {
    _customExercises.add(exercise);
    // Also add it to today's workout for immediate use
    getTodaysWorkout().exercises.add(exercise);
    notifyListeners();
  }

  void _loadInitialData() {
    _workoutHistory = [
      WorkoutSession(
        date: DateUtils.dateOnly(DateTime.now()),
        muscleTarget: 'Chest & Triceps',
        exercises: [
          Exercise(id: 'ex1', name: 'Bench Press', targetMuscle: 'Chest', weight: 60),
          Exercise(id: 'ex2', name: 'Dumbbell Flyes', targetMuscle: 'Chest', weight: 12),
          Exercise(id: 'ex3', name: 'Tricep Dips', targetMuscle: 'Triceps', weight: 0),
        ],
      ),
      WorkoutSession(
        date: DateUtils.dateOnly(DateTime.now().subtract(const Duration(days: 1))),
        muscleTarget: 'Back & Biceps',
        exercises: [
          Exercise(id: 'ex4', name: 'Pull Ups', targetMuscle: 'Back', reps: 8),
          Exercise(id: 'ex5', name: 'Bicep Curls', targetMuscle: 'Biceps', weight: 15),
        ],
      ),
    ];
  }
}
