// lib/models/exercise_model.dart

class Exercise {
  String id;
  String name;
  int sets;
  int reps;
  // The 'weight' property has been completely removed from here
  bool isCompleted;
  String? imagePath;
  String? videoPath;

  Exercise({
    required this.id,
    required this.name,
    this.sets = 3,
    this.reps = 10,
    // The 'weight' property has been completely removed from the constructor
    this.isCompleted = false,
    this.imagePath,
    this.videoPath,
  });
}
