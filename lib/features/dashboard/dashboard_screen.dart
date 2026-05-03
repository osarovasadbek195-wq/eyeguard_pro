import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/hive_helper.dart';
import '../blink_reminder/blink_darkening_overlay.dart';
import '../achievements/achievements_screen.dart';

// Feature toggle providers
final blinkReminderProvider = StateProvider<bool>((ref) => 
    HiveHelper.get('blinkReminder', defaultValue: false) ?? false);
final blinkCreativeModeProvider = StateProvider<bool>((ref) => 
    HiveHelper.get('blinkCreativeMode', defaultValue: false) ?? false);
final breakReminderProvider = StateProvider<bool>((ref) => 
    HiveHelper.get('breakReminder', defaultValue: false) ?? false);
final distanceMonitorProvider = StateProvider<bool>((ref) => 
    HiveHelper.get('distanceMonitor', defaultValue: false) ?? false);
final blueFilterProvider = StateProvider<bool>((ref) => 
    HiveHelper.get('blueFilter', defaultValue: false) ?? false);
final eyeDrynessProvider = StateProvider<bool>((ref) => 
    HiveHelper.get('eyeDryness', defaultValue: false) ?? false);
final childrenModeProvider = StateProvider<bool>((ref) => 
    HiveHelper.get('childrenMode', defaultValue: false) ?? false);

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCreativeMode = ref.watch(blinkCreativeModeProvider);
    
    return Scaffold(
      body: Stack(
        children: [
          Container(
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
            child: SafeArea(
              child: CustomScrollView(
                slivers: [
                  // App Bar
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppStrings.appName,
                            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                  color: AppTheme.primaryColor,
                                ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.settings_outlined),
                            onPressed: () {
                              // Navigate to settings
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Quick Stats
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: _buildQuickStats(context, ref),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 24)),

                  // Feature Toggles
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Text(
                        'Funksiyalar',
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 16)),

                  // Feature Cards
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _buildFeatureCard(
                          context,
                          ref,
                          title: AppStrings.blinkReminder,
                          description: AppStrings.blinkReminderDesc,
                          icon: Icons.visibility,
                          provider: blinkReminderProvider,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(height: 16),
                        _buildFeatureCard(
                          context,
                          ref,
                          title: 'Kreativ Rejim',
                          description: 'Ekranni qoraytiruvchi animatsiya',
                          icon: Icons.animation,
                          provider: blinkCreativeModeProvider,
                          color: Colors.purple,
                        ),
                        const SizedBox(height: 16),
                        _buildFeatureCard(
                          context,
                          ref,
                          title: AppStrings.breakReminder,
                          description: AppStrings.breakReminderDesc,
                          icon: Icons.timer,
                          provider: breakReminderProvider,
                          color: AppTheme.successColor,
                        ),
                        const SizedBox(height: 16),
                        _buildFeatureCard(
                          context,
                          ref,
                          title: AppStrings.distanceMonitor,
                          description: AppStrings.distanceMonitorDesc,
                          icon: Icons.social_distance,
                          provider: distanceMonitorProvider,
                          color: AppTheme.accentColor,
                        ),
                        const SizedBox(height: 16),
                        _buildFeatureCard(
                          context,
                          ref,
                          title: AppStrings.blueFilter,
                          description: AppStrings.blueFilterDesc,
                          icon: Icons.filter_vintage,
                          provider: blueFilterProvider,
                          color: Colors.orange,
                        ),
                        const SizedBox(height: 16),
                        _buildFeatureCard(
                          context,
                          ref,
                          title: AppStrings.eyeDryness,
                          description: AppStrings.eyeDrynessDesc,
                          icon: Icons.water_drop,
                          provider: eyeDrynessProvider,
                          color: AppTheme.warningColor,
                        ),
                        const SizedBox(height: 16),
                        _buildFeatureCard(
                          context,
                          ref,
                          title: AppStrings.childrenMode,
                          description: AppStrings.childrenModeDesc,
                          icon: Icons.child_care,
                          provider: childrenModeProvider,
                          color: Colors.purple,
                        ),
                      ]),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 32)),

                  // Quick Actions
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildQuickActionButton(
                              context,
                              icon: Icons.emoji_events,
                              label: AppStrings.achievements,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const AchievementsScreen()),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildQuickActionButton(
                              context,
                              icon: Icons.fitness_center,
                              label: AppStrings.exercises,
                              onTap: () {
                                // Navigate to exercises
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildQuickActionButton(
                              context,
                              icon: Icons.bar_chart,
                              label: AppStrings.statistics,
                              onTap: () {
                                // Navigate to statistics
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 32)),
                ],
              ),
            ),
          ),
          // Creative Mode Overlay
          if (isCreativeMode)
            BlinkDarkeningOverlay(
              isActive: isCreativeMode,
              darknessLevel: 0.7,
              onDismiss: () {
                ref.read(blinkCreativeModeProvider.notifier).state = false;
                HiveHelper.set('blinkCreativeMode', false);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(AppTheme.glassOpacity),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            context,
            value: '45',
            label: 'min',
            icon: Icons.access_time,
          ),
          _buildStatItem(
            context,
            value: '12',
            label: 'pirpirash',
            icon: Icons.visibility,
          ),
          _buildStatItem(
            context,
            value: '3',
            label: 'tanaffus',
            icon: Icons.timer,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required String value,
    required String label,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryColor, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                color: AppTheme.primaryColor,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required String description,
    required IconData icon,
    required StateProvider<bool> provider,
    required Color color,
  }) {
    final isEnabled = ref.watch(provider);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(AppTheme.glassOpacity),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isEnabled ? color.withOpacity(0.3) : Colors.transparent,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),

          // Text
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

          // Switch
          Switch(
            value: isEnabled,
            onChanged: (value) {
              ref.read(provider.notifier).state = value;
              // Save to Hive
              final key = _getProviderKey(provider);
              HiveHelper.set(key, value);
            },
            activeColor: color,
          ),
        ],
      ),
    );
  }

  String _getProviderKey(StateProvider<bool> provider) {
    if (provider == blinkReminderProvider) return 'blinkReminder';
    if (provider == breakReminderProvider) return 'breakReminder';
    if (provider == distanceMonitorProvider) return 'distanceMonitor';
    if (provider == blueFilterProvider) return 'blueFilter';
    if (provider == eyeDrynessProvider) return 'eyeDryness';
    if (provider == childrenModeProvider) return 'childrenMode';
    return '';
  }

  Widget _buildQuickActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.primaryColor, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
