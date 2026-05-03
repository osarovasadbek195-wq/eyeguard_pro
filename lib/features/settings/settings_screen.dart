import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/hive_helper.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late bool _notificationsEnabled;
  late int _breakIntervalMinutes;
  late double _filterIntensity;

  @override
  void initState() {
    super.initState();
    _notificationsEnabled = HiveHelper.get('notificationsEnabled', defaultValue: true) ?? true;
    _breakIntervalMinutes = HiveHelper.get('breakInterval', defaultValue: 20) ?? 20;
    _filterIntensity = HiveHelper.get('filterIntensity', defaultValue: 0.5) ?? 0.5;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.settings),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: Theme.of(context).brightness == Brightness.light
                ? [AppTheme.lightBackground, AppTheme.primaryColor.withOpacity(0.05)]
                : [AppTheme.darkBackground, AppTheme.primaryColor.withOpacity(0.05)],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Notifications Toggle
            _buildSettingsCard(
              child: SwitchListTile(
                title: const Text('Bildirishnomalar'),
                subtitle: const Text('Ilova xabarlarini yoqish/o\'chirish'),
                value: _notificationsEnabled,
                activeColor: AppTheme.primaryColor,
                onChanged: (val) {
                  setState(() {
                    _notificationsEnabled = val;
                  });
                  HiveHelper.set('notificationsEnabled', val);
                },
              ),
            ),
            const SizedBox(height: 16),

            // Break Interval Settings
            _buildSettingsCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('Tanaffus vaqti: $_breakIntervalMinutes daqiqa',
                        style: Theme.of(context).textTheme.titleMedium),
                  ),
                  Slider(
                    value: _breakIntervalMinutes.toDouble(),
                    min: 10,
                    max: 60,
                    divisions: 10,
                    activeColor: AppTheme.successColor,
                    label: '$_breakIntervalMinutes min',
                    onChanged: (val) {
                      setState(() {
                        _breakIntervalMinutes = val.toInt();
                      });
                      HiveHelper.set('breakInterval', val.toInt());
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Filter Intensity Setting
            _buildSettingsCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('Filtr Kuchi: ${(_filterIntensity * 100).toInt()}%',
                        style: Theme.of(context).textTheme.titleMedium),
                  ),
                  Slider(
                    value: _filterIntensity,
                    min: 0.1,
                    max: 1.0,
                    activeColor: Colors.orange,
                    label: '${(_filterIntensity * 100).toInt()}%',
                    onChanged: (val) {
                      setState(() {
                        _filterIntensity = val;
                      });
                      HiveHelper.set('filterIntensity', val);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(AppTheme.glassOpacity),
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }
}
