import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CameraService {
  CameraController? _controller;
  List<CameraDescription>? _cameras;

  Future<void> initialize() async {
    _cameras = await availableCameras();
  }

  Future<void> startCamera({CameraDescription? camera}) async {
    if (_cameras == null) {
      await initialize();
    }

    final cameraToUse = camera ?? _cameras?.first;
    if (cameraToUse == null) return;

    _controller = CameraController(
      cameraToUse,
      ResolutionPreset.low,
      enableAudio: false,
      fps: 10,
    );

    await _controller!.initialize();
  }

  Future<void> stopCamera() async {
    await _controller?.dispose();
    _controller = null;
  }

  CameraController? get controller => _controller;

  List<CameraDescription>? get cameras => _cameras;

  bool get isInitialized => _controller?.value.isInitialized ?? false;
}

final cameraServiceProvider = Provider<CameraService>((ref) {
  return CameraService();
});
