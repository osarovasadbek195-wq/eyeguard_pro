class DatabaseHelper {
  static Future<void> init() async {}

  static Never get isar {
    throw Exception('Database storage is not enabled.');
  }

  static Future<void> close() async {}
}
