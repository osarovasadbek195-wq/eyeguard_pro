import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../../../core/theme/app_theme.dart';

class CameraTestWidget extends StatefulWidget {
  final bool isActive;
  final ValueChanged<bool> onToggle;

  const CameraTestWidget({
    super.key,
    required this.isActive,
    required this.onToggle,
  });

  @override
  State<CameraTestWidget> createState() => _CameraTestWidgetState();
}

class _CameraTestWidgetState extends State<CameraTestWidget> {
  CameraController? _controller;
  bool _isInitialized = false;
  String _distanceStatus = 'Normal';

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        _controller = CameraController(
          cameras.firstWhere(
            (c) => c.lensDirection == CameraLensDirection.front,
            orElse: () => cameras.first,
          ),
          ResolutionPreset.low,
          enableAudio: false,
        );
        await _controller!.initialize();
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
        }
      }
    } catch (e) {
      print('Camera error: $e');
    }
  }

  void _stopCamera() {
    _controller?.dispose();
    _controller = null;
    if (mounted) {
      setState(() {
        _isInitialized = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: widget.isActive ? AppTheme.accentColor : Colors.transparent,
          width: 2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(AppTheme.glassOpacity),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              // Camera preview
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: _isInitialized && _controller != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: CameraPreview(_controller!),
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              widget.isActive ? Icons.videocam_off : Icons.camera_alt,
                              size: 48,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.isActive
                                  ? 'Kamera o\'chirilgan'
                                  : 'Kamera yoqilmagan',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
              ),
              const SizedBox(height: 16),

              // Distance status
              if (widget.isActive && _isInitialized)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _distanceStatus == 'Normal'
                        ? AppTheme.successColor.withOpacity(0.2)
                        : AppTheme.warningColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _distanceStatus,
                    style: TextStyle(
                      color: _distanceStatus == 'Normal'
                          ? AppTheme.successColor
                          : AppTheme.warningColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              const SizedBox(height: 16),

              // Toggle button
              ElevatedButton.icon(
                onPressed: () async {
                  if (widget.isActive) {
                    _stopCamera();
                  } else {
                    await _initializeCamera();
                  }
                  widget.onToggle(!widget.isActive);
                },
                icon: Icon(widget.isActive ? Icons.videocam_off : Icons.camera),
                label: Text(
                    widget.isActive ? 'Kamerani o\'chirish' : 'Kamerani yoqish'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
