// lib/providers/workout_provider.dart
import 'package:flutter/material.dart';
import '../models/exercise_model.dart';
import '../models/workout_session.dart';

class WorkoutProvider with ChangeNotifier {
  // DATA
  DateTime _selectedDate = DateTime.now();

  final Map<DateTime, double> _weightHistory = {
    DateTime.now().subtract(const Duration(days: 10)): 78.5,
    DateTime.now().subtract(const Duration(days: 7)): 78.0,
    DateTime.now().subtract(const Duration(days: 1)): 77.2,
  };

  final List<Exercise> _masterExerciseList = [
    Exercise(id: 'ex01', name: 'Push-ups'),
    Exercise(id: 'ex02', name: 'Squats'),
    Exercise(id: 'ex03', name: 'Pull-ups'),
  ];

  Map<int, String?> _weeklyPlan = {
    0: 'wk01', // Monday
    1: null,   // Tuesday
    2: 'wk02', // Wednesday
    3: null,   // Thursday
    4: 'wk01', // Friday
    5: null,   // Saturday
    6: null,   // Sunday
  };

  // FIX: This list now correctly creates WorkoutSession objects with an 'id'.
  final List<WorkoutSession> _masterWorkoutList = [
    WorkoutSession(
      id: 'wk01',
      name: 'Upper Body Focus',
      exercises: [
        Exercise(id: 'ex01', name: 'Push-ups'),
        Exercise(id: 'ex03', name: 'Pull-ups'),
      ],
    ),
    WorkoutSession(
      id: 'wk02',
      name: 'Lower Body Strength',
      exercises: [
        Exercise(id: 'ex02', name: 'Squats'),
      ],
    ),
  ];

  // GETTERS
  DateTime get selectedDate => _selectedDate;
  Map<DateTime, double> get weightHistory => _weightHistory;
  List<Exercise> get masterExerciseList => _masterExerciseList;
  Map<int, String?> get weeklyPlan => _weeklyPlan;
  List<WorkoutSession> get masterWorkoutList => _masterWorkoutList; // FIX: Ensures this getter exists.

  WorkoutSession? get selectedWorkout {
    final dayOfWeek = _selectedDate.weekday - 1;
    final workoutId = _weeklyPlan[dayOfWeek];
    if (workoutId == null) return null;
    // FIX: Correctly looks up the workout by its 'id'.
    return _masterWorkoutList.firstWhere((w) => w.id == workoutId);
  }

  // METHODS
  void changeSelectedDate(DateTime newDate) {
    _selectedDate = newDate;
    notifyListeners();
  }
  
  void updateWeeklyPlan(int dayIndex, String? workoutId) {
      _weeklyPlan[dayIndex] = workoutId;
      notifyListeners();
  }
}
