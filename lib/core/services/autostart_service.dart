import 'dart:io';
import 'package:flutter/services.dart';

class AutostartService {
  static const MethodChannel _channel = MethodChannel('eyeguard_pro/autostart');

  Future<bool> requestAutostartPermission() async {
    if (Platform.isAndroid) {
      try {
        final result = await _channel.invokeMethod<bool>('requestAutostartPermission');
        return result ?? false;
      } catch (e) {
        print('Error requesting autostart permission: $e');
        return false;
      }
    } else if (Platform.isWindows) {
      // Windows doesn't require explicit permission for startup
      return true;
    }
    return false;
  }

  Future<bool> enableAutostart() async {
    if (Platform.isAndroid) {
      try {
        final result = await _channel.invokeMethod<bool>('enableAutostart');
        return result ?? false;
      } catch (e) {
        print('Error enabling autostart: $e');
        return false;
      }
    } else if (Platform.isWindows) {
      try {
        final result = await _channel.invokeMethod<bool>('enableAutostart');
        return result ?? false;
      } catch (e) {
        print('Error enabling autostart: $e');
        return false;
      }
    }
    return false;
  }

  Future<bool> disableAutostart() async {
    if (Platform.isAndroid) {
      try {
        final result = await _channel.invokeMethod<bool>('disableAutostart');
        return result ?? false;
      } catch (e) {
        print('Error disabling autostart: $e');
        return false;
      }
    } else if (Platform.isWindows) {
      try {
        final result = await _channel.invokeMethod<bool>('disableAutostart');
        return result ?? false;
      } catch (e) {
        print('Error disabling autostart: $e');
        return false;
      }
    }
    return false;
  }

  Future<bool> isAutostartEnabled() async {
    if (Platform.isAndroid) {
      try {
        final result = await _channel.invokeMethod<bool>('isAutostartEnabled');
        return result ?? false;
      } catch (e) {
        print('Error checking autostart status: $e');
        return false;
      }
    } else if (Platform.isWindows) {
      try {
        final result = await _channel.invokeMethod<bool>('isAutostartEnabled');
        return result ?? false;
      } catch (e) {
        print('Error checking autostart status: $e');
        return false;
      }
    }
    return false;
  }
}

final autostartServiceProvider = Provider<AutostartService>((ref) {
  return AutostartService();
});
