import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import '../../../core/constants/strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/camera_service.dart';
import '../../../core/services/distance_service.dart';
import '../../../models/exercise.dart';

class ExercisePlayer extends StatefulWidget {
  final ExerciseType exerciseType;

  const ExercisePlayer({
    super.key,
    required this.exerciseType,
  });

  @override
  State<ExercisePlayer> createState() => _ExercisePlayerState();
}

class _ExercisePlayerState extends State<ExercisePlayer>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  
  CameraController? _cameraController;
  bool _isTracking = false;
  double _score = 0.0;
  int _correctMoves = 0;
  int _totalMoves = 0;
  
  Timer? _exerciseTimer;
  int _remainingSeconds = 30;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = Tween<double>(begin: -1, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat(reverse: true);
    _startExercise();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _cameraController?.dispose();
    _exerciseTimer?.cancel();
    super.dispose();
  }

  Future<void> _startExercise() async {
    // Start camera for tracking
    try {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        _cameraController = CameraController(
          cameras.firstWhere(
            (c) => c.lensDirection == CameraLensDirection.front,
            orElse: () => cameras.first,
          ),
          ResolutionPreset.low,
          enableAudio: false,
        );
        await _cameraController!.initialize();
        setState(() {
          _isTracking = true;
        });
      }
    } catch (e) {
      print('Camera error: $e');
    }

    // Start timer
    _exerciseTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _remainingSeconds--;
      });
      
      if (_remainingSeconds <= 0) {
        _completeExercise();
      }
    });
  }

  void _completeExercise() {
    _exerciseTimer?.cancel();
    _cameraController?.dispose();
    
    Navigator.of(context).pop({
      'score': _score,
      'correctMoves': _correctMoves,
      'totalMoves': _totalMoves,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: Theme.of(context).brightness == Brightness.light
                ? [
                    AppTheme.darkBackground,
                    AppTheme.primaryColor.withOpacity(0.1),
                  ]
                : [
                    AppTheme.darkBackground,
                    AppTheme.primaryColor.withOpacity(0.1),
                  ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$_remainingSeconds s',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Exercise Animation
              Expanded(
                child: Center(
                  child: AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return _buildExerciseAnimation();
                    },
                  ),
                ),
              ),

              // Camera Preview (small)
              if (_isTracking && _cameraController != null)
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Container(
                    width: 120,
                    height: 90,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.successColor,
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CameraPreview(_cameraController!),
                    ),
                  ),
                ),

              // Score
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildScoreItem('To\'g\'ri', '$_correctMoves', AppTheme.successColor),
                    _buildScoreItem('Ball', '${_score.toStringAsFixed(0)}%', AppTheme.primaryColor),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExerciseAnimation() {
    final value = _animation.value;
    
    switch (widget.exerciseType) {
      case ExerciseType.horizontal:
        return Transform.translate(
          offset: Offset(value * 150, 0),
          child: _buildTargetCircle(),
        );
      case ExerciseType.vertical:
        return Transform.translate(
          offset: Offset(0, value * 100),
          child: _buildTargetCircle(),
        );
      case ExerciseType.diagonal:
        return Transform.translate(
          offset: Offset(value * 100, value * 100),
          child: _buildTargetCircle(),
        );
      case ExerciseType.figure8:
        return Transform.translate(
          offset: Offset(
            math.sin(value * math.pi) * 100,
            math.sin(value * 2 * math.pi) * 50,
          ),
          child: _buildTargetCircle(),
        );
      case ExerciseType.focus:
        return Transform.scale(
          scale: 0.5 + (value + 1) * 0.5,
          child: _buildTargetCircle(),
        );
    }
  }

  Widget _buildTargetCircle() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.primaryColor.withOpacity(0.3),
        border: Border.all(
          color: AppTheme.primaryColor,
          width: 3,
        ),
      ),
      child: Center(
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.primaryColor,
          ),
        ),
      ),
    );
  }

  Widget _buildScoreItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
