import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  Set<String> _inProgressExerciseIds = {};
  Map<String, double> _personalBests = {};
  Map<String, bool> _achievements = {'first_workout': false};
  final List<Workout> _workouts = [ /* ... */ ];
  final List<Exercise> _customExercises = [];
  Map<String, List<String>> _weeklyPlan = { /* ... */ };
  final List<String> availableMuscleGroups = [ /* ... */ ];

  // --- Getters ---
  String get userName => _userName;
  String? get profileImagePath => _profileImagePath;
  DateTime get selectedDate => _selectedDate;
  Map<DateTime, double> get weightHistory => _weightHistory;
  Map<String, List<String>> get weeklyPlan => _weeklyPlan;
  Map<DateTime, Workout> get workoutLog => _workoutLog;
  bool isExerciseInProgressCompleted(String exerciseId) => _inProgressExerciseIds.contains(exerciseId);
  
  // ... other getters are correct and unchanged ...
  int get weeklyStreakCount { final today = DateTime.now(); final startOfWeek = today.subtract(Duration(days: today.weekday - 1)); int streak = 0; for (int i = 0; i < today.weekday; i++) { final day = DateUtils.dateOnly(startOfWeek.add(Duration(days: i))); if (_workoutLog.containsKey(day)) streak++; } return streak; }
  int get weeklyWorkoutDaysCount { return _weeklyPlan.values.where((plan) => !plan.contains('Rest')).length; }
  String get streakMessage { final streak = weeklyStreakCount; if (streak <= 0) return "Let's start the week strong!"; if (streak <= 2) return "Great start!"; if (streak == 3) return "Good progress!"; if (streak == 4) return "Fantastic progress!"; return "Amazing, keep it up!"; }
  double get latestWeight { if (_weightHistory.isEmpty) return 0.0; final sortedDates = _weightHistory.keys.toList()..sort((a, b) => b.compareTo(a)); return _weightHistory[sortedDates.first]!; }
  double? get weightForSelectedDate { final entry = _weightHistory.entries.firstWhere((e) => DateUtils.isSameDay(e.key, _selectedDate), orElse: () => MapEntry(DateTime(0), -1.0)); return entry.value == -1.0 ? null : entry.value; }
  Workout? get selectedWorkout { final dayName = DateFormat('EEEE').format(_selectedDate); final targetMuscles = _weeklyPlan[dayName]; if (targetMuscles == null || targetMuscles.isEmpty || targetMuscles.contains('Rest')) return null; final exercisesForDay = allExercises.where((ex) => targetMuscles.contains(ex.targetMuscle)).toList(); return Workout(id: 'day_${dayName.toLowerCase()}', name: targetMuscles.join(' & '), exercises: exercisesForDay.map((ex) => Exercise(id: ex.id, name: ex.name, targetMuscle: ex.targetMuscle, sets: ex.sets, reps: ex.reps, description: ex.description, imageUrl: ex.imageUrl, videoUrl: ex.videoUrl, isCompleted: isExerciseInProgressCompleted(ex.id))).toList()); }
  Workout? get getTodaysWorkout { final dayName = DateFormat('EEEE').format(DateTime.now()); final targetMuscles = _weeklyPlan[dayName]; if (targetMuscles == null || targetMuscles.isEmpty || targetMuscles.contains('Rest')) return null; final exercisesForDay = allExercises.where((ex) => targetMuscles.contains(ex.targetMuscle)).toList(); return Workout(id: 'today_workout', name: targetMuscles.join(' & '), exercises: exercisesForDay.map((ex) => Exercise(id: ex.id, name: ex.name, targetMuscle: ex.targetMuscle, sets: ex.sets, reps: ex.reps, description: ex.description, imageUrl: ex.imageUrl, videoUrl: ex.videoUrl, isCompleted: isExerciseInProgressCompleted(ex.id))).toList()); }
  List<Exercise> get allExercises { return [..._workouts.expand((workout) => workout.exercises), ..._customExercises]; }
  
  // --- Methods ---
  
  // THE FIX 1: This function is now much smarter.
  void startWorkoutSession() {
    final dateOnly = DateUtils.dateOnly(_selectedDate);
    // Check if a workout is already logged for the selected date.
    if (_workoutLog.containsKey(dateOnly)) {
      // If yes, load the completed exercises from the log into our session.
      final loggedWorkout = _workoutLog[dateOnly]!;
      _inProgressExerciseIds = loggedWorkout.exercises
          .where((ex) => ex.isCompleted)
          .map((ex) => ex.id)
          .toSet();
    } else {
      // If no, start a fresh, empty session.
      _inProgressExerciseIds.clear();
    }
    notifyListeners();
  }

  void toggleInProgressExerciseCompletion(String exerciseId, bool isCompleted) {
    if (isCompleted) { _inProgressExerciseIds.add(exerciseId); }
    else { _inProgressExerciseIds.remove(exerciseId); }
    notifyListeners();
  }

  bool areAllExercisesComplete(List<Exercise> exercises) {
    if (exercises.isEmpty) return false;
    final exerciseIds = exercises.map((e) => e.id).toSet();
    return _inProgressExerciseIds.containsAll(exerciseIds);
  }
  
  void logWorkout(DateTime date, Workout workout) {
    final dateOnly = DateUtils.dateOnly(date);
    final loggedWorkout = Workout(
      id: workout.id, name: workout.name,
      exercises: workout.exercises.map((ex) {
        return Exercise(
          id: ex.id, name: ex.name, targetMuscle: ex.targetMuscle, sets: ex.sets, reps: ex.reps,
          description: ex.description, imageUrl: ex.imageUrl, videoUrl: ex.videoUrl,
          isCompleted: _inProgressExerciseIds.contains(ex.id)
        );
      }).toList(),
    );
    _workoutLog[dateOnly] = loggedWorkout;
    if (_achievements['first_workout'] == false) { _achievements['first_workout'] = true; }
    notifyListeners();
  }
  
  // ... All other methods are unchanged and correct ...
  void updateUserName(String newName) { _userName = newName; notifyListeners(); }
  WorkoutStatus getWorkoutStatusForDate(DateTime date) { final today = DateUtils.dateOnly(DateTime.now()); final dateOnly = DateUtils.dateOnly(date); if (dateOnly.isAfter(today)) return WorkoutStatus.Future; if (_workoutLog.containsKey(dateOnly)) return WorkoutStatus.Completed; final dayName = DateFormat('EEEE').format(dateOnly); final plan = _weeklyPlan[dayName]; if (plan == null || plan.contains('Rest')) return WorkoutStatus.Rest; return WorkoutStatus.Skipped; }
  void deleteLoggedWorkout(DateTime date) { _workoutLog.remove(DateUtils.dateOnly(date)); notifyListeners(); }
  void markAllExercisesAsComplete(List<Exercise> exercises) { for (var ex in exercises) _inProgressExerciseIds.add(ex.id); notifyListeners(); }
  void deleteExercise(String exerciseId) { _customExercises.removeWhere((ex) => ex.id == exerciseId); for (var workout in _workouts) workout.exercises.removeWhere((ex) => ex.id == exerciseId); notifyListeners(); }
  void updateExercise(Exercise updatedExercise) { int index = _customExercises.indexWhere((ex) => ex.id == updatedExercise.id); if (index != -1) { _customExercises[index] = updatedExercise; notifyListeners(); return; } for (var workout in _workouts) { index = workout.exercises.indexWhere((ex) => ex.id == updatedExercise.id); if (index != -1) workout.exercises[index] = updatedExercise; notifyListeners(); return; } }
  void addCustomExercise({ required String name, required String targetMuscle, String? description, required int sets, required int reps, String? imageUrl, String? videoUrl }) { final newExercise = Exercise(id: 'custom_${DateTime.now().toIso8601String()}', name: name, targetMuscle: targetMuscle, description: description, sets: sets, reps: reps, imageUrl: imageUrl, videoUrl: videoUrl); _customExercises.add(newExercise); notifyListeners(); }
  void logUserWeight(double weight) { _weightHistory.removeWhere((key, value) => DateUtils.isSameDay(key, _selectedDate)); _weightHistory[_selectedDate] = weight; notifyListeners(); }
  void changeSelectedDate(DateTime newDate) { _selectedDate = newDate; notifyListeners(); }
  void updateWeeklyPlan(String day, List<String> muscleGroups) { _weeklyPlan[day] = muscleGroups; notifyListeners(); }
  void updateProfilePicture(String imagePath) { _profileImagePath = imagePath; notifyListeners(); }
  void logSet(String exerciseId, int reps, double weight) { if (weight > (_personalBests[exerciseId] ?? 0)) _personalBests[exerciseId] = weight; notifyListeners(); }
}
