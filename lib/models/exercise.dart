import 'package:isar/isar.dart';

part 'exercise.g.dart';

enum ExerciseType {
  horizontal,
  vertical,
  diagonal,
  figure8,
  focus,
}

@Collection()
class Exercise {
  Id id = Isar.autoIncrement;
  
  late ExerciseType type;
  late String name;
  late String description;
  late int durationSeconds;
  
  @Index()
  late DateTime completedAt;
  
  late double score;
  late int repetitions;
  
  Exercise({
    required this.type,
    required this.name,
    required this.description,
    this.durationSeconds = 30,
    DateTime? completedAt,
    this.score = 0.0,
    this.repetitions = 0,
  }) {
    this.completedAt = completedAt ?? DateTime.now();
  }
}
