import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import '../../../core/services/camera_service.dart';
import '../../../core/services/distance_service.dart';
import '../../../core/services/notification_service.dart';

enum BlinkMode {
  simple, // No camera, just visual dot
  advanced, // Camera-based eye tracking
  creative, // Creative darkening animation
}

class BlinkReminderService {
  final CameraService _cameraService;
  final DistanceService _distanceService;
  final NotificationService _notificationService;
  
  Timer? _blinkTimer;
  Timer? _analysisTimer;
  bool _isRunning = false;
  BlinkMode _mode = BlinkMode.simple;
  
  // Blink detection
  int _blinkCount = 0;
  double _currentEar = 0.0;
  List<double> _earHistory = [];
  static const double _earThreshold = 0.25;
  static const int _historyLength = 5;
  
  // Creative mode
  double _darknessLevel = 0.0;
  int _noBlinkSeconds = 0;
  static const int _maxNoBlinkSeconds = 10;
  
  BlinkReminderService(
    this._cameraService,
    this._distanceService,
    this._notificationService,
  );

  Future<void> start(BlinkMode mode) async {
    if (_isRunning) return;
    
    _mode = mode;
    _isRunning = true;
    
    if (mode == BlinkMode.advanced) {
      await _startAdvancedMode();
    } else if (mode == BlinkMode.creative) {
      await _startCreativeMode();
    } else {
      _startSimpleMode();
    }
  }

  void _startSimpleMode() {
    // Visual dot blinks every 5-10 seconds
    _blinkTimer = Timer.periodic(const Duration(seconds: 7), (timer) {
      _showBlinkIndicator();
    });
  }

  Future<void> _startCreativeMode() async {
    // Darkening animation when no blink detected
    _darknessLevel = 0.0;
    _noBlinkSeconds = 0;
    
    _blinkTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _noBlinkSeconds++;
      
      // Gradually increase darkness
      if (_noBlinkSeconds > 3) {
        _darknessLevel = ((_noBlinkSeconds - 3) / _maxNoBlinkSeconds).clamp(0.0, 0.8);
      }
      
      // Reset on blink (simulated)
      if (_noBlinkSeconds > _maxNoBlinkSeconds) {
        _darknessLevel = 0.0;
        _noBlinkSeconds = 0;
      }
    });
  }

  Future<void> _startAdvancedMode() async {
    try {
      await _cameraService.startCamera();
      await _distanceService.initialize();
      
      // Analyze frames every 200ms (5 FPS)
      _analysisTimer = Timer.periodic(const Duration(milliseconds: 200), (_) {
        _analyzeFrame();
      });
      
      // Check blink rate every 5 seconds
      _blinkTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
        _checkBlinkRate();
      });
    } catch (e) {
      print('Error starting advanced blink mode: $e');
      // Fallback to simple mode
      _mode = BlinkMode.simple;
      _startSimpleMode();
    }
  }

  Future<void> _analyzeFrame() async {
    if (!_cameraService.isInitialized) return;
    
    final image = _cameraService.controller?.value;
    if (image == null) return;
    
    final faceDetector = _distanceService.faceDetector;
    if (faceDetector == null) return;
    
    try {
      final inputImage = InputImage.fromBytes(
        bytes: await image.cameraImage.toBytes(),
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: InputImageRotation.rotation0deg,
          format: InputImageFormat.nv21,
          planeData: image.cameraImage.planes.map((plane) {
            return InputImagePlaneMetadata(
              bytesPerRow: plane.bytesPerRow,
              height: image.height,
              width: image.width,
            );
          }).toList(),
        ),
      );
      
      final faces = await faceDetector.processImage(inputImage);
      if (faces.isNotEmpty) {
        final face = faces.first;
        _calculateEar(face);
      }
    } catch (e) {
      // Silent error handling
    }
  }

  void _calculateEar(Face face) {
    // Get eye landmarks
    final leftEye = face.landmarks[FaceLandmarkType.leftEye];
    final rightEye = face.landmarks[FaceLandmarkType.rightEye];
    
    if (leftEye == null || rightEye == null) return;
    
    // Calculate Eye Aspect Ratio (EAR)
    // Simplified calculation using landmark positions
    final leftEar = _calculateSingleEar(leftEye);
    final rightEar = _calculateSingleEar(rightEye);
    
    _currentEar = (leftEar + rightEar) / 2;
    _earHistory.add(_currentEar);
    
    if (_earHistory.length > _historyLength) {
      _earHistory.removeAt(0);
    }
    
    // Detect blink (sudden drop in EAR)
    if (_earHistory.length >= 3) {
      final avgBefore = _earHistory.sublist(0, _earHistory.length - 1).reduce((a, b) => a + b) / (_earHistory.length - 1);
      if (_currentEar < _earThreshold && avgBefore > _earThreshold * 1.5) {
        _blinkCount++;
      }
    }
  }

  double _calculateSingleEar(FaceLandmark eyeLandmark) {
    // Simplified EAR calculation
    // In production, use proper eye contour points
    final points = eyeLandmark.position;
    return 0.3; // Placeholder - calculate from actual landmarks
  }

  void _checkBlinkRate() {
    // If blink rate is too low (< 10 blinks per 5 seconds), notify user
    if (_blinkCount < 10) {
      _notificationService.showNotification(
        id: 100,
        title: 'Pirpiratingiz!',
        body: 'Ko\'zlarini ko\'proq pirpiratingiz',
      );
    }
    _blinkCount = 0;
  }

  void _showBlinkIndicator() {
    // This would show a small blinking dot on screen edge
    // Implementation would use an overlay widget
  }

  Future<void> stop() async {
    _isRunning = false;
    _blinkTimer?.cancel();
    _analysisTimer?.cancel();
    _blinkTimer = null;
    _analysisTimer = null;
    
    if (_mode == BlinkMode.advanced) {
      await _cameraService.stopCamera();
    }
  }

  bool get isRunning => _isRunning;
  BlinkMode get mode => _mode;
  int get blinkCount => _blinkCount;
  double get darknessLevel => _darknessLevel;
  int get noBlinkSeconds => _noBlinkSeconds;

  void resetCreativeMode() {
    _darknessLevel = 0.0;
    _noBlinkSeconds = 0;
  }
}

final blinkReminderServiceProvider = Provider<BlinkReminderService>((ref) {
  final cameraService = ref.watch(cameraServiceProvider);
  final distanceService = ref.watch(distanceServiceProvider);
  final notificationService = ref.watch(notificationServiceProvider);
  
  return BlinkReminderService(
    cameraService,
    distanceService,
    notificationService,
  );
});
