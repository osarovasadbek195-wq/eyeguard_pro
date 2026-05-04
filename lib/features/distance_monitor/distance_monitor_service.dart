import 'dart:async';
import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import '../../../core/services/camera_service.dart';
import '../../../core/services/distance_service.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/services/statistics_service.dart';
import '../../../core/utils/hive_helper.dart';

class DistanceMonitorService {
  final CameraService _cameraService;
  final DistanceService _distanceService;
  final NotificationService _notificationService;
  final StatisticsService _statisticsService;
  
  Timer? _monitoringTimer;
  bool _isRunning = false;
  double _distanceThreshold = 0.7;
  int _alertCount = 0;
  
  DistanceMonitorService(
    this._cameraService,
    this._distanceService,
    this._notificationService,
    this._statisticsService,
  );

  Future<void> start() async {
    if (_isRunning) return;
    
    _isRunning = true;
    _loadSettings();
    
    try {
      await _cameraService.startCamera();
      await _distanceService.initialize();
      
      // Monitor every 500ms (2 FPS for distance)
      _monitoringTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
        _monitorDistance();
      });
    } catch (e) {
      print('Error starting distance monitor: $e');
      _isRunning = false;
    }
  }

  void _loadSettings() {
    _distanceThreshold = HiveHelper.get('distanceThreshold', defaultValue: 0.7) ?? 0.7;
  }

  Future<void> _monitorDistance() async {
    if (!_cameraService.isInitialized) return;
    
    final faceDetector = _distanceService.faceDetector;
    if (faceDetector == null) return;
    
    try {
      final image = _cameraService.controller?.value;
      if (image == null) return;
      
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
        final distance = _distanceService.calculateDistance(face);
        
        if (distance != null && _distanceService.isTooClose(distance, _distanceThreshold)) {
          _handleTooClose();
        }
      }
    } catch (e) {
      // Silent error handling
    }
  }

  void _handleTooClose() {
    _alertCount++;
    
    // Record distance alert
    _statisticsService.recordDistanceAlert();
    
    // Show warning every 3rd alert to avoid spam
    if (_alertCount % 3 == 0) {
      _notificationService.showNotification(
        id: 300,
        title: 'Telefon juda yaqin!',
        body: 'Telefonni uzoqlashtiring',
      );
    }
    
    // Could also blur screen or show red frame
  }

  Future<void> stop() async {
    _isRunning = false;
    _monitoringTimer?.cancel();
    _monitoringTimer = null;
    await _cameraService.stopCamera();
  }

  void setDistanceThreshold(double threshold) {
    _distanceThreshold = threshold;
    HiveHelper.set('distanceThreshold', threshold);
  }

  bool get isRunning => _isRunning;
  double get distanceThreshold => _distanceThreshold;
}

final distanceMonitorServiceProvider = Provider<DistanceMonitorService>((ref) {
  final cameraService = ref.watch(cameraServiceProvider);
  final distanceService = ref.watch(distanceServiceProvider);
  final notificationService = ref.watch(notificationServiceProvider);
  final statisticsService = ref.watch(statisticsServiceProvider);
  
  return DistanceMonitorService(
    cameraService,
    distanceService,
    notificationService,
    statisticsService,
  );
});
