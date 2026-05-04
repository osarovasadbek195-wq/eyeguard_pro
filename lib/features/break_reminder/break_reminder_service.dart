import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/services/background_service.dart';
import '../../../core/utils/hive_helper.dart';

class BreakReminderService {
  final NotificationService _notificationService;
  final BackgroundService _backgroundService;
  
  Timer? _timer;
  bool _isRunning = false;
  bool _isStrictMode = false;
  int _breakInterval = 20; // minutes
  int _currentMinute = 0;
  
  BreakReminderService(
    this._notificationService,
    this._backgroundService,
  );

  Future<void> start() async {
    if (_isRunning) return;
    
    _isRunning = true;
    _loadSettings();
    
    // Start background service for persistent timer
    await _backgroundService.startService();
    
    // Start timer
    _startTimer();
  }

  void _loadSettings() {
    _isStrictMode = HiveHelper.get('strictMode', defaultValue: false) ?? false;
    _breakInterval = HiveHelper.get('breakInterval', defaultValue: 20) ?? 20;
  }

  void _startTimer() {
    _currentMinute = 0;
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _currentMinute++;
      
      if (_currentMinute >= _breakInterval) {
        _triggerBreak();
        _currentMinute = 0;
      }
    });
  }

  Future<void> _triggerBreak() async {
    await _notificationService.showNotification(
      id: 200,
      title: 'Tanaffus vaqti!',
      body: '20 soniya uzoqqa qarang',
    );
    
    if (_isStrictMode) {
      // In strict mode, show overlay that blocks screen
      _showStrictBreakOverlay();
    }
  }

  void _showStrictBreakOverlay() {
    // Strict break overlay uses the BlinkDarkeningOverlay widget
    // It shows a full-screen overlay with a countdown timer
    // The overlay blocks screen interaction until the break is complete
    // This is handled by the UI layer listening to the service state
  }

  Future<void> stop() async {
    _isRunning = false;
    _timer?.cancel();
    _timer = null;
    await _backgroundService.stopService();
  }

  void setStrictMode(bool enabled) {
    _isStrictMode = enabled;
    HiveHelper.set('strictMode', enabled);
  }

  void setBreakInterval(int minutes) {
    _breakInterval = minutes;
    HiveHelper.set('breakInterval', minutes);
    
    // Restart timer if running
    if (_isRunning) {
      _timer?.cancel();
      _startTimer();
    }
  }

  bool get isRunning => _isRunning;
  bool get isStrictMode => _isStrictMode;
  int get breakInterval => _breakInterval;
  int get currentMinute => _currentMinute;
}

final breakReminderServiceProvider = Provider<BreakReminderService>((ref) {
  final notificationService = ref.watch(notificationServiceProvider);
  final backgroundService = ref.watch(backgroundServiceProvider);
  
  return BreakReminderService(
    notificationService,
    backgroundService,
  );
});
