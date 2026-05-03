import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/strings.dart';

class BreakTestWidget extends StatefulWidget {
  final bool isActive;
  final ValueChanged<bool> onToggle;

  const BreakTestWidget({
    super.key,
    required this.isActive,
    required this.onToggle,
  });

  @override
  State<BreakTestWidget> createState() => _BreakTestWidgetState();
}

class _BreakTestWidgetState extends State<BreakTestWidget> {
  Timer? _timer;
  int _countdown = 20;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startBreakTimer() {
    setState(() {
      _countdown = 20;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() {
          _countdown--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: widget.isActive ? AppTheme.successColor : Colors.transparent,
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
              // Timer display
              Container(
                height: 150,
                decoration: BoxDecoration(
                  color: widget.isActive
                      ? AppTheme.successColor.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: widget.isActive
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$_countdown',
                              style: Theme.of(context)
                                  .textTheme
                                  .displayLarge
                                  ?.copyWith(
                                    fontSize: 64,
                                    color: AppTheme.successColor,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'soniya',
                              style: TextStyle(color: AppTheme.successColor),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.timer_outlined,
                              size: 48,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tanaffus demo',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 24),

              // Toggle button
              ElevatedButton.icon(
                onPressed: () {
                  if (!widget.isActive) {
                    _startBreakTimer();
                  } else {
                    _timer?.cancel();
                  }
                  widget.onToggle(!widget.isActive);
                },
                icon: Icon(
                    widget.isActive ? Icons.stop_circle : Icons.play_circle),
                label: Text(widget.isActive ? 'To\'xtatish' : 'Boshlash'),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      widget.isActive ? AppTheme.warningColor : AppTheme.successColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
