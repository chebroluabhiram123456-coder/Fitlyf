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

  // FIX: Added 'muscleGroup' to every Exercise
  final List<Exercise> _masterExerciseList = [
    Exercise(id: 'ex01', name: 'Push-ups', muscleGroup: 'Chest'),
    Exercise(id: 'ex02', name: 'Squats', muscleGroup: 'Legs'),
    Exercise(id: 'ex03', name: 'Pull-ups', muscleGroup: 'Back'),
    Exercise(id: 'ex04', name: 'Plank', muscleGroup: 'Core'),
    Exercise(id: 'ex05', name: 'Lunges', muscleGroup: 'Legs'),
    Exercise(id: 'ex06', name: 'Bench Press', muscleGroup: 'Chest'),
    Exercise(id: 'ex07', name: 'Deadlift', muscleGroup: 'Back'),
  ];

  Map<int, String?> _weeklyPlan = {
    0: 'wk01', 1: null, 2: 'wk02', 3: null, 4: 'wk03', 5: null, 6: null,
  };

  // FIX: Added 'muscleGroup' to every Exercise within each WorkoutSession
  final List<WorkoutSession> _masterWorkoutList = [
    WorkoutSession(
      id: 'wk01',
      name: 'Upper Body Focus',
      exercises: [
        Exercise(id: 'ex01', name: 'Push-ups', muscleGroup: 'Chest'),
        Exercise(id: 'ex03', name: 'Pull-ups', muscleGroup: 'Back'),
        Exercise(id: 'ex06', name: 'Bench Press', muscleGroup: 'Chest'),
      ],
    ),
    WorkoutSession(
      id: 'wk02',
      name: 'Lower Body Strength',
      exercises: [
        Exercise(id: 'ex02', name: 'Squats', muscleGroup: 'Legs'),
        Exercise(id: 'ex05', name: 'Lunges', muscleGroup: 'Legs'),
        Exercise(id: 'ex07', name: 'Deadlift', muscleGroup: 'Back'),
      ],
    ),
    WorkoutSession(
      id: 'wk03',
      name: 'Full Body Core',
      exercises: [
        Exercise(id: 'ex01', name: 'Push-ups', muscleGroup: 'Chest'),
        Exercise(id: 'ex02', name: 'Squats', muscleGroup: 'Legs'),
        Exercise(id: 'ex04', name: 'Plank', muscleGroup: 'Core'),
      ],
    ),
  ];

  // GETTERS
  DateTime get selectedDate => _selectedDate;
  Map<DateTime, double> get weightHistory => _weightHistory;
  List<Exercise> get masterExerciseList => _masterExerciseList;
  Map<int, String?> get weeklyPlan => _weeklyPlan;
  List<WorkoutSession> get masterWorkoutList => _masterWorkoutList;

  WorkoutSession? get selectedWorkout {
    final dayOfWeek = _selectedDate.weekday - 1;
    final workoutId = _weeklyPlan[dayOfWeek];
    if (workoutId == null) return null;
    return _masterWorkoutList.firstWhere((w) => w.id == workoutId);
  }

  // METHODS
  void changeSelectedDate(DateTime newDate) {
    _selectedDate = newDate;
    notifyListeners();
  }

  void toggleExerciseCompletion(String exerciseId) {
    final workout = selectedWorkout;
    if (workout != null) {
      final exercise = workout.exercises.firstWhere((ex) => ex.id == exerciseId);
      exercise.isCompleted = !exercise.isCompleted;
      notifyListeners();
    }
  }

  void addExerciseToMasterList(Exercise newExercise) {
    _masterExerciseList.add(newExercise);
    notifyListeners();
  }

  void updateWeeklyPlan(int dayIndex, String? workoutId) {
    _weeklyPlan[dayIndex] = workoutId;
    notifyListeners();
  }
}
