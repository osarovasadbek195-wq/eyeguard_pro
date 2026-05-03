import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class DistanceService {
  FaceDetector? _faceDetector;

  Future<void> initialize() async {
    final options = FaceDetectorOptions(
      enableContours: true,
      enableClassification: true,
      enableLandmarks: true,
      enableTracking: true,
      minFaceSize: 0.15,
      performanceMode: FaceDetectorMode.accurate,
    );
    _faceDetector = FaceDetector(options: options);
  }

  double? calculateDistance(Face face) {
    // Calculate relative distance based on face bounding box
    final boundingBox = face.boundingBox;
    final faceWidth = boundingBox.width;
    final faceHeight = boundingBox.height;
    
    // Average face size in pixels
    // This is a simplified calculation - in production, calibrate with known distance
    final averageFaceSize = (faceWidth + faceHeight) / 2;
    
    // Approximate distance (inverse relationship)
    // Larger face = closer, smaller face = farther
    // Normalize to 0-1 range where 1 = very close, 0 = far
    final normalizedDistance = 1.0 - (averageFaceSize / 500.0);
    
    return normalizedDistance.clamp(0.0, 1.0);
  }

  bool isTooClose(double distance, double threshold) {
    return distance > threshold;
  }

  void dispose() {
    _faceDetector?.close();
  }

  FaceDetector? get faceDetector => _faceDetector;
}

final distanceServiceProvider = Provider<DistanceService>((ref) {
  return DistanceService();
});
