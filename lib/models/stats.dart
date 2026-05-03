class DailyStats {
  int id = 0;
  
  late DateTime date;
  
  late int screenTimeMinutes;
  late int blinkCount;
  late int distanceAlerts;
  late int breaksTaken;
  late int breaksMissed;
  late double breakCompliance;
  late int exerciseScore;
  
  DailyStats({
    required this.date,
    this.screenTimeMinutes = 0,
    this.blinkCount = 0,
    this.distanceAlerts = 0,
    this.breaksTaken = 0,
    this.breaksMissed = 0,
    this.breakCompliance = 0.0,
    this.exerciseScore = 0,
  });
  
  int get totalBreaks => breaksTaken + breaksMissed;
}
