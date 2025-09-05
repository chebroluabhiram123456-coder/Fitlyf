// lib/providers/workout_provider.dart

import 'package:flutter/material.dart';
import 'package:fitlyf/models/exercise_model.dart';
import 'package:fitlyf/models/workout_session.dart';

class WorkoutProvider with ChangeNotifier {
  final Map<DateTime, double> _weightHistory = {
    DateTime.now().subtract(const Duration(days: 30)): 75.0,
    DateTime.now().subtract(const Duration(days: 20)): 74.5,
    DateTime.now().subtract(const Duration(days: 10)): 74.0,
    DateTime.now(): 73.5,
  };
  
  final Map<String, String> _weeklyPlan = {
    'Monday': 'Chest, Shoulders, Core',
    'Tuesday': 'Legs & Back',
    'Wednesday': 'Arms',
    'Thursday': 'Chest & Shoulders',
    'Friday': 'Legs',
    'Saturday': 'Cardio & Abs',
    'Sunday': 'Rest Day',
  };

  final List<WorkoutSession> _allWorkouts = [
    WorkoutSession(
      id: 'ws1',
      date: DateUtils.dateOnly(DateTime.now()),
      name: 'Chest, Shoulders, Core',
      exercises: [
        Exercise(id: 'ex1', name: 'Barbell Incline Bench Press'),
        Exercise(id: 'ex2', name: 'Barbell Push Press'),
      ],
    ),
    WorkoutSession(
      id: 'ws2',
      date: DateUtils.dateOnly(DateTime.now().add(const Duration(days: 1))),
      name: 'Legs & Back',
      exercises: [
        Exercise(id: 'ex3', name: 'Squats'),
        Exercise(id: 'ex4', name: 'Deadlifts'),
      ],
    ),
  ];

  DateTime _selectedDate = DateUtils.dateOnly(DateTime.now());
  late WorkoutSession _selectedWorkout;

  WorkoutProvider() {
    _loadWorkoutForDate(_selectedDate);
  }

  DateTime get selectedDate => _selectedDate;
  WorkoutSession get selectedWorkout => _selectedWorkout;
  Map<String, String> get weeklyPlan => _weeklyPlan;
  Map<DateTime, double> get weightHistory => _weightHistory;
  double get latestWeight => _weightHistory.entries.last.value;

  List<Exercise> get allExercises {
    return _allWorkouts.expand((session) => session.exercises).toList();
  }

  void _loadWorkoutForDate(DateTime date) {
    _selectedWorkout = _allWorkouts.firstWhere(
      (session) => DateUtils.isSameDay(session.date, date),
      orElse: () => WorkoutSession(
        id: DateTime.now().toIso801String(),
        date: date,
        name: 'Rest Day',
        exercises: [],
      ),
    );
  }

  void changeSelectedDate(DateTime newDate) {
    _selectedDate = newDate;
    _loadWorkoutForDate(newDate);
    notifyListeners();
  }
  
  void updateWeeklyPlan(String day, String muscleGroup) {
      _weeklyPlan[day] = muscleGroup;
      notifyListeners();
  }

  void addExercise(Exercise exercise) {
    _selectedWorkout.exercises.add(exercise);
    notifyListeners();
  }

  void toggleExerciseCompletion(String exerciseId) {
    final exercise = _selectedWorkout.exercises.firstWhere((ex) => ex.id == exerciseId);
    exercise.isCompleted = !exercise.isCompleted;
    notifyListeners();
  }

  // --- NEW METHOD TO LOG WEIGHT ---
  void logUserWeight(double newWeight) {
    // Adds a new entry for today's date. If an entry for today already exists, it's updated.
    _weightHistory[DateUtils.dateOnly(DateTime.now())] = newWeight;
    notifyListeners();
  }
}
