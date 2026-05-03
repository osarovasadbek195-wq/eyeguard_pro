import 'package:isar/isar.dart';

part 'achievement.g.dart';

@Collection()
class Achievement {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String title;
  
  late String description;
  late String iconCode;
  
  late bool isUnlocked;
  late DateTime? unlockedAt;

  Achievement({
    required this.title,
    required this.description,
    required this.iconCode,
    this.isUnlocked = false,
    this.unlockedAt,
  });
}
