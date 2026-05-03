import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveHelper {
  static const String settingsBox = 'settingsBox';
  static const String isFirstRunKey = 'isFirstRun';
  
  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(settingsBox);
  }
  
  static bool get isFirstRun {
    final box = Hive.box(settingsBox);
    return box.get(isFirstRunKey, defaultValue: true);
  }
  
  static Future<void> setFirstRun(bool value) async {
    final box = Hive.box(settingsBox);
    await box.put(isFirstRunKey, value);
  }
  
  static T? get<T>(String key, {T? defaultValue}) {
    final box = Hive.box(settingsBox);
    return box.get(key, defaultValue: defaultValue);
  }
  
  static Future<void> set(String key, dynamic value) async {
    final box = Hive.box(settingsBox);
    await box.put(key, value);
  }
}

// Riverpod Providers
final isFirstRunProvider = Provider<bool>((ref) {
  return HiveHelper.isFirstRun;
});
