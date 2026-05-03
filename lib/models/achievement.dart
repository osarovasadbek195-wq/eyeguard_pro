class Achievement {
  int id = 0;

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
