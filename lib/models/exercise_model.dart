// lib/models/exercise_model.dart

class Exercise {
  String id;
  String name;
  String targetMuscle; // ADDED THIS
  String description;  // ADDED THIS
  int sets;
  int reps;
  bool isCompleted;
  String? imagePath;
  String? videoPath;

  Exercise({
    required this.id,
    required this.name,
    required this.targetMuscle, // ADDED THIS
    required this.description,  // ADDED THIS
    this.sets = 3,
    this.reps = 10,
    this.isCompleted = false,
    this.imagePath,
    this.videoPath,
  });
}
