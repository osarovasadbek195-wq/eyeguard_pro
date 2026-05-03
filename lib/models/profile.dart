import 'package:isar/isar.dart';

part 'profile.g.dart';

@Collection()
class Profile {
  Id id = Isar.autoIncrement;
  
  late String name;
  
  @Index()
  late bool isGlasses;
  
  late double distanceThreshold;
  late DateTime createdAt;
  late DateTime lastUsed;
  
  String? pin;
  
  Profile({
    required this.name,
    required this.isGlasses,
    this.distanceThreshold = 0.7,
    required DateTime createdAt,
    required DateTime lastUsed,
    this.pin,
  }) {
    this.createdAt = createdAt;
    this.lastUsed = lastUsed;
  }
}
