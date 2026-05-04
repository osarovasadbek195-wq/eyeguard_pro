import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/hive_helper.dart';
import 'core/utils/database_helper.dart';
import 'core/services/notification_service.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/dashboard/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await HiveHelper.init();
  
  // Initialize Isar database
  await DatabaseHelper.init();
  
  // Initialize notifications
  await NotificationService.initialize();
  
  runApp(
    const ProviderScope(
      child: EyeGuardApp(),
    ),
  );
}

class EyeGuardApp extends ConsumerWidget {
  const EyeGuardApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFirstRun = ref.watch(isFirstRunProvider);
    
    return MaterialApp(
      title: 'EyeGuard Pro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: isFirstRun ? const OnboardingScreen() : const DashboardScreen(),
    );
  }
}
