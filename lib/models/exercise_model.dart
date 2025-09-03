import 'dart.io';

class Exercise {
  String id;
  String name;
  String targetMuscle;
  int sets;
  int reps;
  double weight; // in Kilograms
  bool isCompleted;
  String? imagePath;
  String? videoPath;

  Exercise({
    required this.id,
    required this.name,
    required this.targetMuscle,
    this.sets = 3,
    this.reps = 10,
    this.weight = 10.0,
    this.isCompleted = false,
    this.imagePath,
    this.videoPath,
  });
}
