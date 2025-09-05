// lib/providers/workout_provider.dart

import 'package:flutter/material.dart';
import 'package:fitlyf/models/exercise_model.dart';
import 'package:fitlyf/models/workout_session.dart';

class WorkoutProvider with ChangeNotifier {
  // --- DATABASE SIMULATION ---
  // A map to hold the plan for each day of the week.
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
      date: DateUtils.dateOnly(DateTime.now()),
      name: 'Chest, Shoulders, Core',
      exercises: [
        Exercise(id: 'ex1', name: 'Barbell Incline Bench Press', weight: 45),
        Exercise(id: 'ex2', name: 'Barbell Push Press', weight: 30),
      ],
    ),
    WorkoutSession(
      date: DateUtils.dateOnly(DateTime.now().add(const Duration(days: 1))),
      name: 'Legs & Back',
      exercises: [
        Exercise(id: 'ex3', name: 'Squats', weight: 80),
        Exercise(id: 'ex4', name: 'Deadlifts', weight: 100),
      ],
    ),
  ];

  DateTime _selectedDate = DateUtils.dateOnly(DateTime.now());
  late WorkoutSession _selectedWorkout;

  WorkoutProvider() {
    _loadWorkoutForDate(_selectedDate);
  }

  // --- GETTERS ---
  DateTime get selectedDate => _selectedDate;
  WorkoutSession get selectedWorkout => _selectedWorkout;
  Map<String, String> get weeklyPlan => _weeklyPlan;

  // --- METHODS ---
  void _loadWorkoutForDate(DateTime date) {
    _selectedWorkout = _allWorkouts.firstWhere(
      (session) => DateUtils.isSameDay(session.date, date),
      orElse: () => WorkoutSession(
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
  
  // New method to update the weekly plan
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
}
