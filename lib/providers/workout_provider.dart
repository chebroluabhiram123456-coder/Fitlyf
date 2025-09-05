import 'package:flutter/material.dart';
import '../models/exercise_model.dart';
import '../models/workout_model.dart';

class WorkoutProvider with ChangeNotifier {
  DateTime _selectedDate = DateTime.now();
  Map<DateTime, double> _weightHistory = {
    DateTime.now().subtract(Duration(days: 1)): 75.5,
    DateTime.now(): 76.0,
  };

  final List<Workout> _workouts = [
    Workout(
      id: 'w1',
      name: 'Full Body Strength A',
      exercises: [
        Exercise(id: 'ex1', name: 'Barbell Incline Bench Press', targetMuscle: 'Chest', sets: 4, reps: 8),
        Exercise(id: 'ex2', name: 'Barbell Push Press', targetMuscle: 'Shoulders', sets: 3, reps: 10),
      ],
    ),
    Workout(
      id: 'w2',
      name: 'Full Body Strength B',
      exercises: [
        Exercise(id: 'ex3', name: 'Squats', targetMuscle: 'Legs', sets: 5, reps: 5),
        Exercise(id: 'ex4', name: 'Deadlifts', targetMuscle: 'Back', sets: 1, reps: 5),
      ],
    ),
  ];

  Map<String, String> _weeklyPlan = {
    'Monday': 'w1',
    'Tuesday': 'Rest',
    'Wednesday': 'w2',
    'Thursday': 'Rest',
    'Friday': 'w1',
    'Saturday': 'Cardio',
    'Sunday': 'Rest',
  };

  DateTime get selectedDate => _selectedDate;
  Map<DateTime, double> get weightHistory => _weightHistory;

  double get latestWeight {
    if (_weightHistory.isEmpty) return 0.0;
    final sortedDates = _weightHistory.keys.toList()..sort((a, b) => b.compareTo(a));
    return _weightHistory[sortedDates.first]!;
  }

  Workout? get selectedWorkout {
    final dayOfWeek = _selectedDate.weekday;
    final workoutId = _weeklyPlan[
        ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'][dayOfWeek - 1]
    ];
    if (workoutId == null || workoutId == 'Rest' || workoutId == 'Cardio') {
      return null;
    }
    return _workouts.firstWhere((w) => w.id == workoutId);
  }

  List<Exercise> get allExercises {
    return _workouts.expand((workout) => workout.exercises).toList();
  }

  void logUserWeight(double weight) {
    _weightHistory[DateTime.now()] = weight;
    notifyListeners();
  }

  void changeSelectedDate(DateTime newDate) {
    _selectedDate = newDate;
    notifyListeners();
  }

  void updateWeeklyPlan(String day, String workoutId) {
    _weeklyPlan[day] = workoutId;
    notifyListeners();
  }

  // THIS IS THE FINAL FIX: The missing function
  void toggleExerciseCompletion(String exerciseId, bool isCompleted) {
    try {
      final exercise = allExercises.firstWhere((ex) => ex.id == exerciseId);
      exercise.isCompleted = isCompleted;
      notifyListeners();
    } catch (e) {
      // Handle case where exercise is not found, if necessary
      print("Error finding exercise to toggle: $e");
    }
  }
}
