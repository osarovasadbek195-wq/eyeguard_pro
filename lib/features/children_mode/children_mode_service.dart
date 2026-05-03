import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/hive_helper.dart';

class ChildrenModeService {
  bool _isEnabled = false;
  int _screenTimeLimit = 30; // minutes
  bool _strictDistance = true;
  String? _parentPin;

  ChildrenModeService() {
    _loadSettings();
  }

  void _loadSettings() {
    _isEnabled = HiveHelper.get('childrenModeEnabled', defaultValue: false) ?? false;
    _screenTimeLimit = HiveHelper.get('childrenScreenTimeLimit', defaultValue: 30) ?? 30;
    _strictDistance = HiveHelper.get('childrenStrictDistance', defaultValue: true) ?? true;
    _parentPin = HiveHelper.get('parentPin');
  }

  Future<void> enable(String pin) async {
    _isEnabled = true;
    _parentPin = pin;
    await HiveHelper.set('childrenModeEnabled', true);
    await HiveHelper.set('parentPin', pin);
  }

  Future<void> disable(String pin) async {
    if (pin == _parentPin) {
      _isEnabled = false;
      await HiveHelper.set('childrenModeEnabled', false);
    } else {
      throw Exception('Noto\'g\'ri PIN');
    }
  }

  void setScreenTimeLimit(int minutes) {
    _screenTimeLimit = minutes;
    HiveHelper.set('childrenScreenTimeLimit', minutes);
  }

  void setStrictDistance(bool strict) {
    _strictDistance = strict;
    HiveHelper.set('childrenStrictDistance', strict);
  }

  bool verifyPin(String pin) {
    return pin == _parentPin;
  }

  bool get isEnabled => _isEnabled;
  int get screenTimeLimit => _screenTimeLimit;
  bool get strictDistance => _strictDistance;
}

final childrenModeServiceProvider = Provider<ChildrenModeService>((ref) {
  return ChildrenModeService();
});
