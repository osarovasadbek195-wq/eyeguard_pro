import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import '../../../core/constants/strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/hive_helper.dart';
import '../../../core/services/camera_service.dart';
import '../../../core/services/distance_service.dart';
import 'widgets/filter_test_widget.dart';
import 'widgets/camera_test_widget.dart';
import 'widgets/break_test_widget.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  int _currentPage = 0;
  bool _filterTestActive = false;
  bool _cameraTestActive = false;
  bool _breakTestActive = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _requestPermissions() async {
    await Permission.camera.request();
    await Permission.systemAlertWindow.request();
    await Permission.notification.request();
  }

  Future<void> _completeOnboarding() async {
    await HiveHelper.setFirstRun(false);
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/');
    }
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _skipOnboarding() {
    _completeOnboarding();
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
                    AppTheme.lightBackground,
                    AppTheme.lightBackground.withOpacity(0.8),
                    AppTheme.primaryColor.withOpacity(0.1),
                  ]
                : [
                    AppTheme.darkBackground,
                    AppTheme.darkBackground.withOpacity(0.8),
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
                    Text(
                      AppStrings.appName,
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            color: AppTheme.primaryColor,
                          ),
                    ),
                    TextButton(
                      onPressed: _skipOnboarding,
                      child: Text(
                        AppStrings.skip,
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Page Indicator
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  children: List.generate(3, (index) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(right: 8),
                      height: 4,
                      width: _currentPage == index ? 32 : 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? AppTheme.primaryColor
                            : AppTheme.primaryColor.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    );
                  }),
                ),
              ),

              // Content
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  children: [
                    _buildFilterPage(),
                    _buildCameraPage(),
                    _buildBreakPage(),
                  ],
                ),
              ),

              // Bottom Navigation
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_currentPage > 0)
                      TextButton(
                        onPressed: () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: Text(
                          AppStrings.cancel,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                    )
                    else
                      const SizedBox(),
                    ElevatedButton(
                      onPressed: _nextPage,
                      child: Text(
                        _currentPage == 2 ? AppStrings.finish : AppStrings.next,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterPage() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.filter_vintage,
              size: 64,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 32),

          // Title
          Text(
            AppStrings.filterTestTitle,
            style: Theme.of(context).textTheme.displayLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Description
          Text(
            AppStrings.filterTestDescription,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Filter Test Widget
          FilterTestWidget(
            isActive: _filterTestActive,
            onToggle: (active) {
              setState(() {
                _filterTestActive = active;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCameraPage() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.accentColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.face_retouching_natural,
              size: 64,
              color: AppTheme.accentColor,
            ),
          ),
          const SizedBox(height: 32),

          // Title
          Text(
            AppStrings.cameraTestTitle,
            style: Theme.of(context).textTheme.displayLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Description
          Text(
            AppStrings.cameraTestDescription,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Camera Test Widget
          CameraTestWidget(
            isActive: _cameraTestActive,
            onToggle: (active) async {
              if (active) {
                await _requestPermissions();
              }
              setState(() {
                _cameraTestActive = active;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBreakPage() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.successColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.timer,
              size: 64,
              color: AppTheme.successColor,
            ),
          ),
          const SizedBox(height: 32),

          // Title
          Text(
            AppStrings.breakTestTitle,
            style: Theme.of(context).textTheme.displayLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Description
          Text(
            AppStrings.breakTestDescription,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Break Test Widget
          BreakTestWidget(
            isActive: _breakTestActive,
            onToggle: (active) {
              setState(() {
                _breakTestActive = active;
              });
            },
          ),
        ],
      ),
    );
  }
}
