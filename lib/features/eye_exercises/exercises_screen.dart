import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/exercise.dart';
import 'exercise_player.dart';

class ExercisesScreen extends ConsumerWidget {
  const ExercisesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.eyeExercises),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: Theme.of(context).brightness == Brightness.light
                ? [
                    AppTheme.lightBackground,
                    AppTheme.primaryColor.withOpacity(0.05),
                  ]
                : [
                    AppTheme.darkBackground,
                    AppTheme.primaryColor.withOpacity(0.05),
                  ],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _buildExerciseCard(
              context,
              title: AppStrings.horizontal,
              description: 'Chapdan o\'ngga ko\'z harakati',
              icon: Icons.arrow_forward,
              color: AppTheme.primaryColor,
              type: ExerciseType.horizontal,
            ),
            const SizedBox(height: 16),
            _buildExerciseCard(
              context,
              title: AppStrings.vertical,
              description: 'Yuqoridan pastga ko\'z harakati',
              icon: Icons.arrow_downward,
              color: AppTheme.successColor,
              type: ExerciseType.vertical,
            ),
            const SizedBox(height: 16),
            _buildExerciseCard(
              context,
              title: AppStrings.diagonal,
              description: 'Diagonal yo\'nalishda harakat',
              icon: Icons.open_in_full,
              color: AppTheme.accentColor,
              type: ExerciseType.diagonal,
            ),
            const SizedBox(height: 16),
            _buildExerciseCard(
              context,
              title: AppStrings.figure8,
              description: 'Sakkizlik shaklida harakat',
              icon: Icons.all_inclusive,
              color: Colors.orange,
              type: ExerciseType.figure8,
            ),
            const SizedBox(height: 16),
            _buildExerciseCard(
              context,
              title: AppStrings.focus,
              description: 'Yaqin-uzoq fokuslash',
              icon: Icons.center_focus_strong,
              color: AppTheme.warningColor,
              type: ExerciseType.focus,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required ExerciseType type,
  }) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ExercisePlayer(exerciseType: type),
          ),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(AppTheme.glassOpacity),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.play_circle_outline,
              color: color,
              size: 32,
            ),
          ],
        ),
      ),
    );
  }
}
