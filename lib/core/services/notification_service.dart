import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationService {
  static Future<void> initialize() async {
    // No-op - flutter_local_notifications temporarily disabled
  }

  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    // No-op - flutter_local_notifications temporarily disabled
  }

  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    // No-op - flutter_local_notifications temporarily disabled
  }

  static Future<void> cancelNotification(int id) async {
    // No-op - flutter_local_notifications temporarily disabled
  }

  static Future<void> cancelAllNotifications() async {
    // No-op - flutter_local_notifications temporarily disabled
  }
}

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});
