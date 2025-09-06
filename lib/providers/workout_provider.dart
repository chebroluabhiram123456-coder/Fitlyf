import 'package.flutter/material.dart';
import 'package.intl/intl.dart';
import '../models/exercise_model.dart';
import '../models/workout_model.dart';
import '../models/set_log_model.dart';

enum WorkoutStatus { Completed, Skipped, Scheduled, Rest, Future }

class WorkoutProvider with ChangeNotifier {
  String? _profileImagePath;
  String _userName = "User";
  DateTime _selectedDate = DateTime.now();
  Map<DateTime, double> _weightHistory = {};
  Map<DateTime, Workout> _workoutLog = {};
  final List<Exercise> _customExercises = [];
  final List<Workout> _workouts = [
    Workout( id: 'w1', name: 'Full Body A', exercises: [
        Exercise(id: 'ex1', name: 'Barbell Incline Bench Press', targetMuscle: 'Chest', sets: 4, reps: 8),
        Exercise(id: 'ex2', name: 'Barbell Push Press', targetMuscle: 'Shoulders', sets: 3, reps: 10),
    ]),
    Workout( id: 'w2', name: 'Full Body B', exercises: [
        Exercise(id: 'ex3', name: 'Squats', targetMuscle: 'Legs', sets: 5, reps: 5),
        Exercise(id: 'ex4', name: 'Deadlifts', targetMuscle: 'Back', sets: 1, reps: 5),
    ]),
  ];
  
  // THE FIX 1: The weekly plan now stores a LIST of muscle groups for each day.
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

  // --- Getters ---
  String get userName => _userName;
  String? get profileImagePath => _profileImagePath;
  DateTime get selectedDate => _selectedDate;
  Map<DateTime, double> get weightHistory => _weightHistory;
  Map<String, List<String>> get weeklyPlan => _weeklyPlan;
  Map<DateTime, Workout> get workoutLog => _workoutLog;
  Map<String, double> get personalBests => {};
  Map<String, bool> get achievements => {'first_workout': false};

  double get latestWeight {
    if (_weightHistory.isEmpty) return 0.0;
    final sortedDates = _weightHistory.keys.toList()..sort((a, b) => b.compareTo(a));
    return _weightHistory[sortedDates.first]!;
  }
  
  double? get weightForSelectedDate {
    final entry = _weightHistory.entries.firstWhere((e) => DateUtils.isSameDay(e.key, _selectedDate), orElse: () => MapEntry(DateTime(0), -1.0));
    return entry.value == -1.0 ? null : entry.value;
  }

  Workout? get selectedWorkout {
    final dayName = DateFormat('EEEE').format(_selectedDate);
    final targetMuscles = _weeklyPlan[dayName];
    if (targetMuscles == null || targetMuscles.isEmpty || targetMuscles.contains('Rest')) return null;
    final exercisesForDay = allExercises.where((ex) => targetMuscles.contains(ex.targetMuscle)).toList();
    return Workout(id: 'day_${dayName.toLowerCase()}', name: targetMuscles.join(' & '), exercises: exercisesForDay);
  }
  
  Workout? get getTodaysWorkout {
    final dayName = DateFormat('EEEE').format(DateTime.now());
    final targetMuscles = _weeklyPlan[dayName];
    if (targetMuscles == null || targetMuscles.isEmpty || targetMuscles.contains('Rest')) return null;
    final exercisesForDay = allExercises.where((ex) => targetMuscles.contains(ex.targetMuscle)).toList();
    return Workout(id: 'today_workout', name: targetMuscles.join(' & '), exercises: exercisesForDay);
  }

  List<Exercise> get allExercises {
    return [..._workouts.expand((workout) => workout.exercises), ..._customExercises];
  }

  // --- Methods ---
  
  // THE FIX 2: This function now accepts a LIST of muscle groups.
  void updateWeeklyPlan(String day, List<String> muscleGroups) {
    _weeklyPlan[day] = muscleGroups;
    notifyListeners();
  }

  // ... All other methods are correct ...
  void updateUserName(String newName) { _userName = newName; notifyListeners(); }
  WorkoutStatus getWorkoutStatusForDate(DateTime date) { final today = DateUtils.dateOnly(DateTime.now()); final dateOnly = DateUtils.dateOnly(date); if (dateOnly.isAfter(today)) return WorkoutStatus.Future; if (_workoutLog.containsKey(dateOnly)) return WorkoutStatus.Completed; final dayName = DateFormat('EEEE').format(dateOnly); final plan = _weeklyPlan[dayName]; if (plan == null || plan.contains('Rest')) return WorkoutStatus.Rest; return WorkoutStatus.Skipped; }
  void logWorkout(DateTime date, Workout workout) { _workoutLog[DateUtils.dateOnly(date)] = workout; if (achievements['first_workout'] == false) { achievements['first_workout'] = true; } notifyListeners(); }
  void deleteLoggedWorkout(DateTime date) { _workoutLog.remove(DateUtils.dateOnly(date)); notifyListeners(); }
  void markAllExercisesAsComplete(List<Exercise> exercises) { for (var ex in exercises) { try { allExercises.firstWhere((e) => e.id == ex.id).isCompleted = true; } catch (e) {} } notifyListeners(); }
  void logSet(String exerciseId, int reps, double weight) { if (weight > (personalBests[exerciseId] ?? 0)) { personalBests[exerciseId] = weight; } notifyListeners(); }
  void deleteExercise(String exerciseId) { _customExercises.removeWhere((ex) => ex.id == exerciseId); for (var workout in _workouts) { workout.exercises.removeWhere((ex) => ex.id == exerciseId); } notifyListeners(); }
  void updateExercise(Exercise updatedExercise) { int index = _customExercises.indexWhere((ex) => ex.id == updatedExercise.id); if (index != -1) { _customExercises[index] = updatedExercise; notifyListeners(); return; } for (var workout in _workouts) { index = workout.exercises.indexWhere((ex) => ex.id == updatedExercise.id); if (index != -1) { workout.exercises[index] = updatedExercise; notifyListeners(); return; } } }
  void addCustomExercise({ required String name, required String targetMuscle, String? description, required int sets, required int reps, String? imageUrl, String? videoUrl }) { final newExercise = Exercise(id: 'custom_${DateTime.now().toIso8601String()}', name: name, targetMuscle: targetMuscle, description: description, sets: sets, reps: reps, imageUrl: imageUrl, videoUrl: videoUrl); _customExercises.add(newExercise); notifyListeners(); }
  void logUserWeight(double weight) { _weightHistory.removeWhere((key, value) => DateUtils.isSameDay(key, _selectedDate)); _weightHistory[_selectedDate] = weight; notifyListeners(); }
  void changeSelectedDate(DateTime newDate) { _selectedDate = newDate; notifyListeners(); }
  void toggleExerciseCompletion(String exerciseId, bool isCompleted) { allExercises.firstWhere((ex) => ex.id == exerciseId).isCompleted = isCompleted; notifyListeners(); }
  void updateProfilePicture(String imagePath) { _profileImagePath = imagePath; notifyListeners(); }
}
