import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import '../../../core/utils/hive_helper.dart';

class BlueFilterService {
  bool _isActive = false;
  double _intensity = 0.5;
  Color _filterColor = const Color(0xFFFFA500); // Orange
  
  // Platform channel for overlay
  static const MethodChannel _channel = MethodChannel('eyeguard_pro/filter');

  Future<void> start() async {
    if (_isActive) return;
    
    _isActive = true;
    _loadSettings();
    
    try {
      await _channel.invokeMethod('startFilter', {
        'intensity': _intensity,
        'color': _filterColor.value,
      });
    } catch (e) {
      print('Error starting blue filter: $e');
    }
  }

  Future<void> stop() async {
    if (!_isActive) return;
    
    _isActive = false;
    
    try {
      await _channel.invokeMethod('stopFilter');
    } catch (e) {
      print('Error stopping blue filter: $e');
    }
  }

  void _loadSettings() {
    _intensity = HiveHelper.get('filterIntensity', defaultValue: 0.5) ?? 0.5;
    final colorValue = HiveHelper.get('filterColor', defaultValue: 0xFFFFA500);
    if (colorValue != null) {
      _filterColor = Color(colorValue);
    }
  }

  Future<void> setIntensity(double intensity) async {
    _intensity = intensity.clamp(0.0, 1.0);
    HiveHelper.set('filterIntensity', _intensity);
    
    if (_isActive) {
      await _channel.invokeMethod('updateFilter', {
        'intensity': _intensity,
      });
    }
  }

  Future<void> setColor(Color color) async {
    _filterColor = color;
    HiveHelper.set('filterColor', color.value);
    
    if (_isActive) {
      await _channel.invokeMethod('updateFilter', {
        'color': color.value,
      });
    }
  }

  Future<void> setWarmMode(double warmth) async {
    // Adjust color based on warmth (0 = cool, 1 = warm)
    final r = 255;
    final g = (165 * (1 - warmth) + 255 * warmth).toInt();
    final b = (0 * (1 - warmth) + 200 * warmth).toInt();
    
    await setColor(Color.fromARGB(255, r, g, b));
  }

  bool get isActive => _isActive;
  double get intensity => _intensity;
  Color get filterColor => _filterColor;
}

final blueFilterServiceProvider = Provider<BlueFilterService>((ref) {
  return BlueFilterService();
});
