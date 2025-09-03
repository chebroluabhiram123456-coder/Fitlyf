import 'package:flutter/material.dart';
import 'package:fitlyf/models/exercise_model.dart';
import 'package:fitlyf/models/workout_session.dart';

class WorkoutProvider with ChangeNotifier {
  // --- (Existing code for exercises and workouts) ---
  final List<Exercise> _masterExerciseList = [];
  final Map<DateTime, WorkoutSession> _dailyWorkouts = {};
  DateTime _selectedDate = DateUtils.dateOnly(DateTime.now());
  late WorkoutSession _selectedWorkout;

  // --- NEW: Weight Tracking Data ---
  final Map<DateTime, double> _weightHistory = {};

  WorkoutProvider() {
    _loadWorkoutForDate(_selectedDate);
  }

  // --- GETTERS ---
  DateTime get selectedDate => _selectedDate;
  WorkoutSession get selectedWorkout => _selectedWorkout;
  List<Exercise> get masterExerciseList => _masterExerciseList;
  Map<DateTime, double> get weightHistory => _weightHistory;
  
  double? get todaysWeight {
    return _weightHistory[DateUtils.dateOnly(DateTime.now())];
  }

  // --- METHODS ---
  // --- (Existing methods for workouts) ---
  void _loadWorkoutForDate(DateTime date) {
    _selectedWorkout = _dailyWorkouts[date] ?? WorkoutSession(
      date: date,
      name: 'Plan a workout!',
      exercises: [],
    );
  }

  void changeSelectedDate(DateTime newDate) {
    _selectedDate = newDate;
    _loadWorkoutForDate(newDate);
    notifyListeners();
  }

  void addExerciseToMasterList(Exercise exercise) {
    _masterExerciseList.add(exercise);
    notifyListeners();
  }

  void createWorkoutForDay(DateTime date, String muscleGroup) {
    final exercisesForMuscle = _masterExerciseList
        .where((ex) => ex.muscleGroup.toLowerCase() == muscleGroup.toLowerCase())
        .toList();
    final newWorkout = WorkoutSession(
      date: date,
      name: muscleGroup,
      exercises: exercisesForMuscle,
    );
    _dailyWorkouts[date] = newWorkout;
    if (DateUtils.isSameDay(_selectedDate, date)) {
      _selectedWorkout = newWorkout;
    }
    notifyListeners();
  }

  void toggleExerciseCompletion(String exerciseId) {
    final exercise = _selectedWorkout.exercises.firstWhere((ex) => ex.id == exerciseId);
    exercise.isCompleted = !exercise.isCompleted;
    notifyListeners();
  }

  // --- NEW: Method to log weight ---
  void logWeight(double weight) {
    final today = DateUtils.dateOnly(DateTime.now());
    _weightHistory[today] = weight;
    notifyListeners(); // This is crucial to update the UI
  }
}
