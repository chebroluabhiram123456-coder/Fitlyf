class Exercise {
  final String id;
  final String name;
  final String targetMuscle;
  bool isCompleted; // This property is needed for the progress screen

  Exercise({
    required this.id,
    required this.name,
    required this.targetMuscle,
    this.isCompleted = false, // Default to false
  });
}
