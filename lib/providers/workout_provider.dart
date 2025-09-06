import 'package:flutter/material.dart';
import '../models/exercise_model.dart';
import '../models/workout_model.dart';

class WorkoutProvider with ChangeNotifier {
  String? _profileImagePath;

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

  Map<String, List<String>> _weeklyPlan = {
    'Monday': ['Chest', 'Biceps'],
    'Tuesday': ['Back', 'Triceps'],
    'Wednesday': ['Legs', 'Shoulders'],
    'Thursday': ['Rest'],
    'Friday': ['Chest', 'Back'],
    'Saturday': ['Abs'],
    'Sunday': ['Rest'],
  };

  final List<String> availableMuscleGroups = [
    'Chest', 'Back', 'Shoulders', 'Biceps', 'Triceps', 'Legs', 'Abs', 'Rest'
  ];

  // Getters
  String? get profileImagePath => _profileImagePath;
  DateTime get selectedDate => _selectedDate;
  Map<DateTime, double> get weightHistory => _weightHistory;
  Map<String, List<String>> get weeklyPlan => _weeklyPlan;

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

  Workout? get selectedWorkout {
    final dayOfWeek = _selectedDate.weekday;
    final dayName = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'][dayOfWeek - 1];
    final targetMuscles = _weeklyPlan[dayName];

    if (targetMuscles == null || targetMuscles.isEmpty || targetMuscles.contains('Rest')) {
      return null;
    }

    final exercisesForDay = allExercises.where((ex) => targetMuscles.contains(ex.targetMuscle)).toList();

    return Workout(
      id: 'day_${dayName.toLowerCase()}',
      name: targetMuscles.join(' & '),
      exercises: exercisesForDay,
    );
  }

  List<Exercise> get allExercises {
    return [..._workouts.expand((workout) => workout.exercises), ..._customExercises];
  }

  // Methods
  void updateProfilePicture(String imagePath) {
    _profileImagePath = imagePath;
    notifyListeners();
  }

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
  
  void updateWeeklyPlan(String day, List<String> muscleGroups) {
    _weeklyPlan[day] = muscleGroups;
    notifyListeners();
  }

  void toggleExerciseCompletion(String exerciseId, bool isCompleted) {
    final exercise = allExercises.firstWhere((ex) => ex.id == exerciseId);
    exercise.isCompleted = isCompleted;
    notifyListeners();
  }
}
