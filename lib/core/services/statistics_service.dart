import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/stats.dart';

class StatisticsService {
  static const String statsBox = 'statsBox';
  
  late Box<DailyStats> _box;
  
  Future<void> init() async {
    if (!Hive.isBoxOpen(statsBox)) {
      await Hive.openBox<DailyStats>(statsBox);
    }
    _box = Hive.box<DailyStats>(statsBox);
  }
  
  Future<void> recordScreenTime(int minutes) async {
    final today = _getTodayKey();
    final stats = await _getOrCreateStats(today);
    stats.screenTimeMinutes += minutes;
    await _box.put(today, stats);
  }
  
  Future<void> recordBlink(int count) async {
    final today = _getTodayKey();
    final stats = await _getOrCreateStats(today);
    stats.blinkCount += count;
    await _box.put(today, stats);
  }
  
  Future<void> recordDistanceAlert() async {
    final today = _getTodayKey();
    final stats = await _getOrCreateStats(today);
    stats.distanceAlerts++;
    await _box.put(today, stats);
  }
  
  Future<void> recordBreakTaken() async {
    final today = _getTodayKey();
    final stats = await _getOrCreateStats(today);
    stats.breaksTaken++;
    stats.breakCompliance = stats.breaksTaken / stats.totalBreaks;
    await _box.put(today, stats);
  }
  
  Future<void> recordBreakMissed() async {
    final today = _getTodayKey();
    final stats = await _getOrCreateStats(today);
    stats.breaksMissed++;
    stats.breakCompliance = stats.breaksTaken / stats.totalBreaks;
    await _box.put(today, stats);
  }
  
  Future<void> recordExerciseScore(int score) async {
    final today = _getTodayKey();
    final stats = await _getOrCreateStats(today);
    stats.exerciseScore += score;
    await _box.put(today, stats);
  }
  
  Future<DailyStats?> getStats(DateTime date) async {
    final key = _formatDateKey(date);
    return _box.get(key);
  }
  
  Future<List<DailyStats>> getStatsForPeriod(String period) async {
    final now = DateTime.now();
    final startDate = _getStartDate(period, now);
    
    final allStats = _box.values.toList();
    return allStats.where((stat) {
      return stat.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
             stat.date.isBefore(now.add(const Duration(days: 1)));
    }).toList();
  }
  
  Future<Map<String, dynamic>> getSummary(String period) async {
    final stats = await getStatsForPeriod(period);
    
    if (stats.isEmpty) {
      return {
        'totalScreenTime': 0,
        'avgScreenTime': 0,
        'totalBreaks': 0,
        'breakCompliance': 0.0,
        'totalBlinks': 0,
        'totalDistanceAlerts': 0,
        'totalExerciseScore': 0,
      };
    }
    
    final totalScreenTime = stats.fold(0, (sum, s) => sum + s.screenTimeMinutes);
    final totalBreaks = stats.fold(0, (sum, s) => sum + s.totalBreaks);
    final totalBlinks = stats.fold(0, (sum, s) => sum + s.blinkCount);
    final totalDistanceAlerts = stats.fold(0, (sum, s) => sum + s.distanceAlerts);
    final totalExerciseScore = stats.fold(0, (sum, s) => sum + s.exerciseScore);
    final avgCompliance = stats.fold(0.0, (sum, s) => sum + s.breakCompliance) / stats.length;
    
    return {
      'totalScreenTime': totalScreenTime,
      'avgScreenTime': totalScreenTime ~/ stats.length,
      'totalBreaks': totalBreaks,
      'breakCompliance': avgCompliance,
      'totalBlinks': totalBlinks,
      'totalDistanceAlerts': totalDistanceAlerts,
      'totalExerciseScore': totalExerciseScore,
    };
  }
  
  DateTime _getStartDate(String period, DateTime now) {
    switch (period) {
      case 'daily':
        return DateTime(now.year, now.month, now.day);
      case 'weekly':
        return now.subtract(const Duration(days: 7));
      case 'monthly':
        return DateTime(now.year, now.month, 1);
      default:
        return DateTime(now.year, now.month, now.day);
    }
  }
  
  String _getTodayKey() {
    return _formatDateKey(DateTime.now());
  }
  
  String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
  
  Future<DailyStats> _getOrCreateStats(String key) async {
    DailyStats? stats = _box.get(key);
    if (stats == null) {
      stats = DailyStats(date: DateTime.now());
      await _box.put(key, stats);
    }
    return stats;
  }
}

final statisticsServiceProvider = Provider<StatisticsService>((ref) {
  return StatisticsService();
});
