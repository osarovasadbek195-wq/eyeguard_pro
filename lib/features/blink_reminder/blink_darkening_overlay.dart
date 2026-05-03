import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

class BlinkDarkeningOverlay extends StatefulWidget {
  final bool isActive;
  final VoidCallback onDismiss;
  final double darknessLevel; // 0.0 to 1.0

  const BlinkDarkeningOverlay({
    super.key,
    required this.isActive,
    required this.onDismiss,
    this.darknessLevel = 0.0,
  });

  @override
  State<BlinkDarkeningOverlay> createState() => _BlinkDarkeningOverlayState();
}

class _BlinkDarkeningOverlayState extends State<BlinkDarkeningOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _darknessAnimation;
  Timer? _darknessTimer;
  double _currentDarkness = 0.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _darknessAnimation = Tween<double>(begin: 0.0, end: widget.darknessLevel).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    if (widget.isActive) {
      _startAnimation();
    }
  }

  @override
  void didUpdateWidget(BlinkDarkeningOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _startAnimation();
      } else {
        _stopAnimation();
      }
    }
  }

  void _startAnimation() {
    _animationController.repeat(reverse: true);
    _darknessTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_currentDarkness < widget.darknessLevel) {
        setState(() {
          _currentDarkness = (_currentDarkness + 0.02).clamp(0.0, widget.darknessLevel);
        });
      }
    });
  }

  void _stopAnimation() {
    _animationController.stop();
    _animationController.reset();
    _darknessTimer?.cancel();
    setState(() {
      _currentDarkness = 0.0;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _darknessTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 0.5 + _pulseAnimation.value * 0.3,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(_currentDarkness * 0.3),
                Colors.black.withOpacity(_currentDarkness * 0.6),
                Colors.black.withOpacity(_currentDarkness * 0.9),
              ],
              stops: const [0.0, 0.3, 0.6, 1.0],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Blinking eye icon
                Transform.scale(
                  scale: 1.0 + _pulseAnimation.value * 0.2,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.1),
                      border: Border.all(
                        color: Colors.white.withOpacity(_pulseAnimation.value * 0.5),
                        width: 3,
                      ),
                    ),
                    child: Icon(
                      Icons.visibility,
                      size: 60,
                      color: Colors.white.withOpacity(_pulseAnimation.value),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Text
                Text(
                  'Ko\'zlarini yumib chiqing!',
                  style: TextStyle(
                    color: Colors.white.withOpacity(_pulseAnimation.value),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        blurRadius: 10,
                        color: Colors.black.withOpacity(0.5),
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Yumish tugmasini bosing',
                  style: TextStyle(
                    color: Colors.white.withOpacity(_pulseAnimation.value * 0.7),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 32),
                // Dismiss button
                ElevatedButton.icon(
                  onPressed: widget.onDismiss,
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Yumdim'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.2),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
