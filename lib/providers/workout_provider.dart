import 'package:flutter/material.dart';
import '../models/exercise_model.dart';
import '../models/workout_model.dart';

class WorkoutProvider with ChangeNotifier {
  DateTime _selectedDate = DateTime.now();
  Map<DateTime, double> _weightHistory = {
    DateTime.now().subtract(const Duration(days: 3)): 75.0,
    DateTime.now().subtract(const Duration(days: 2)): 75.5,
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
  
  final List<Exercise> _customExercises = [];

  // THE FIX 1: The weekly plan now stores muscle groups, not workout IDs.
  Map<String, String> _weeklyPlan = {
    'Monday': 'Chest',
    'Tuesday': 'Back',
    'Wednesday': 'Legs',
    'Thursday': 'Rest',
    'Friday': 'Shoulders',
    'Saturday': 'Biceps', // You can now be this specific!
    'Sunday': 'Rest',
  };

  // THE FIX 2: A definitive list of muscle groups for the dropdown.
  final List<String> availableMuscleGroups = [
    'Chest', 'Back', 'Shoulders', 'Biceps', 'Triceps', 'Legs', 'Abs', 'Rest'
  ];

  // Getters
  DateTime get selectedDate => _selectedDate;
  Map<DateTime, double> get weightHistory => _weightHistory;
  Map<String, String> get weeklyPlan => _weeklyPlan;

  double get latestWeight {
    if (_weightHistory.isEmpty) return 0.0;
    final sortedDates = _weightHistory.keys.toList()..sort((a, b) => b.compareTo(a));
    return _weightHistory[sortedDates.first]!;
  }
  
  double? get weightForSelectedDate {
    final entry = _weightHistory.entries.firstWhere(
      (entry) => DateUtils.isSameDay(entry.key, _selectedDate),
      orElse: () => MapEntry(DateTime(0), -1.0),
    );
    return entry.value == -1.0 ? null : entry.value;
  }

  // THE FIX 3: The selectedWorkout getter is now much smarter.
  // It builds a workout on-the-fly based on the day's target muscle.
  Workout? get selectedWorkout {
    final dayOfWeek = _selectedDate.weekday;
    final dayName = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'][dayOfWeek - 1];
    final targetMuscle = _weeklyPlan[dayName];

    if (targetMuscle == null || targetMuscle == 'Rest') {
      return null;
    }

    // Find all exercises that match the target muscle for the day.
    final exercisesForDay = allExercises.where((ex) => ex.targetMuscle == targetMuscle).toList();

    if (exercisesForDay.isEmpty) {
      // Return a workout with an empty list if no exercises exist for that muscle yet
      return Workout(id: 'day_${dayName.toLowerCase()}', name: '$targetMuscle Day', exercises: []);
    }

    // Create a new Workout object just for today.
    return Workout(
      id: 'day_${dayName.toLowerCase()}',
      name: '$targetMuscle Day',
      exercises: exercisesForDay,
    );
  }

  List<Exercise> get allExercises {
    return [..._workouts.expand((workout) => workout.exercises), ..._customExercises];
  }

  // Methods
  void addCustomExercise({
    required String name,
    required String targetMuscle,
    required int sets,
    required int reps,
    String? imageUrl,
    String? videoUrl,
  }) {
    final newExercise = Exercise(
      id: 'custom_${DateTime.now().toIso8601String()}',
      name: name,
      targetMuscle: targetMuscle,
      sets: sets,
      reps: reps,
      imageUrl: imageUrl,
      videoUrl: videoUrl,
    );
    _customExercises.add(newExercise);
    notifyListeners();
  }
  
  void logUserWeight(double weight) {
    _weightHistory.removeWhere((key, value) => DateUtils.isSameDay(key, _selectedDate));
    _weightHistory[_selectedDate] = weight;
    notifyListeners();
  }

  void changeSelectedDate(DateTime newDate) {
    _selectedDate = newDate;
    notifyListeners();
  }
  
  // This function now updates the plan with a muscle group name.
  void updateWeeklyPlan(String day, String muscleGroup) {
    _weeklyPlan[day] = muscleGroup;
    notifyListeners();
  }

  void toggleExerciseCompletion(String exerciseId, bool isCompleted) {
    final exercise = allExercises.firstWhere((ex) => ex.id == exerciseId);
    exercise.isCompleted = isCompleted;
    notifyListeners();
  }
}
