import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../../models/profile.dart';
import '../../models/exercise.dart';
import '../../models/stats.dart';
import '../../models/achievement.dart';

class DatabaseHelper {
  static Isar? _isar;

  static Future<void> init() async {
    if (_isar != null) return;

    final dir = await getApplicationDocumentsDirectory();
    
    _isar = await Isar.open(
      [
        ProfileSchema,
        ExerciseSchema,
        DailyStatsSchema,
        AchievementSchema,
      ],
      directory: dir.path,
      inspector: true,
    );
  }

  static Isar get isar {
    if (_isar == null) {
      throw Exception('Database not initialized. Call init() first.');
    }
    return _isar!;
  }

  static Future<void> close() async {
    await _isar?.close();
    _isar = null;
  }
}
