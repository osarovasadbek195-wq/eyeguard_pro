class Profile {
  int id = 0;
  
  late String name;
  
  late bool isGlasses;
  
  late double distanceThreshold;
  late DateTime createdAt;
  late DateTime lastUsed;
  
  String? pin;
  
  Profile({
    required this.name,
    required this.isGlasses,
    this.distanceThreshold = 0.7,
    DateTime? createdAt,
    DateTime? lastUsed,
    this.pin,
  })  : createdAt = createdAt ?? DateTime.now(),
        lastUsed = lastUsed ?? DateTime.now();
}
