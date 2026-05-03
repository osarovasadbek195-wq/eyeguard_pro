import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/achievement.dart';

class AchievementsScreen extends ConsumerStatefulWidget {
  const AchievementsScreen({super.key});

  @override
  ConsumerState<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends ConsumerState<AchievementsScreen> {
  final List<Achievement> _achievements = [
    Achievement(
      title: AppStrings.beginner,
      description: AppStrings.beginnerDesc,
      iconCode: 'emoji_events',
      isUnlocked: true,
      unlockedAt: DateTime.now(),
    ),
    Achievement(
      title: AppStrings.eagleEye,
      description: AppStrings.eagleEyeDesc,
      iconCode: 'visibility',
      isUnlocked: false,
    ),
    Achievement(
      title: AppStrings.healthMaster,
      description: AppStrings.healthMasterDesc,
      iconCode: 'workspace_premium',
      isUnlocked: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.achievements),
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
        child: ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: _achievements.length,
          itemBuilder: (context, index) {
            final item = _achievements[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildAchievementCard(item),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAchievementCard(Achievement achievement) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: achievement.isUnlocked
            ? Colors.white.withOpacity(AppTheme.glassOpacity)
            : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: achievement.isUnlocked
              ? AppTheme.accentColor.withOpacity(0.5)
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: achievement.isUnlocked
                  ? AppTheme.accentColor.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getIcon(achievement.iconCode),
              color: achievement.isUnlocked ? AppTheme.accentColor : Colors.grey,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: achievement.isUnlocked ? null : Colors.grey,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  achievement.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: achievement.isUnlocked ? null : Colors.grey,
                      ),
                ),
                if (achievement.isUnlocked && achievement.unlockedAt != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Olingan vaqti: ${achievement.unlockedAt!.day}/${achievement.unlockedAt!.month}/${achievement.unlockedAt!.year}',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppTheme.successColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (!achievement.isUnlocked)
            const Icon(Icons.lock, color: Colors.grey),
        ],
      ),
    );
  }

  IconData _getIcon(String code) {
    switch (code) {
      case 'emoji_events':
        return Icons.emoji_events;
      case 'visibility':
        return Icons.visibility;
      case 'workspace_premium':
        return Icons.workspace_premium;
      default:
        return Icons.star;
    }
  }
}
