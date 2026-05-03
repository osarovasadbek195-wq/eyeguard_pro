import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/profile.dart';

class ProfilesScreen extends ConsumerStatefulWidget {
  const ProfilesScreen({super.key});

  @override
  ConsumerState<ProfilesScreen> createState() => _ProfilesScreenState();
}

class _ProfilesScreenState extends ConsumerState<ProfilesScreen> {
  List<Profile> _profiles = [];

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    // Load profiles from Isar
    // For now, use dummy data
    setState(() {
      _profiles = [
        Profile(
          name: 'Asosiy',
          isGlasses: false,
          distanceThreshold: 0.7,
        ),
      ];
    });
  }

  void _showAddProfileDialog() {
    final nameController = TextEditingController();
    bool hasGlasses = false;
    double distanceThreshold = 0.7;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(AppStrings.addProfile),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Ism',
                  hintText: 'Profil nomi',
                ),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Ko\'zoynak'),
                subtitle: const Text('Ko\'zoynak taqishadi'),
                value: hasGlasses,
                onChanged: (value) {
                  setDialogState(() {
                    hasGlasses = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              Text('Masofa chegarasi: ${(distanceThreshold * 100).toInt()}%'),
              Slider(
                value: distanceThreshold,
                onChanged: (value) {
                  setDialogState(() {
                    distanceThreshold = value;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppStrings.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  setState(() {
                    _profiles.add(Profile(
                      name: nameController.text,
                      isGlasses: hasGlasses,
                      distanceThreshold: distanceThreshold,
                    ));
                  });
                  Navigator.of(context).pop();
                }
              },
              child: Text(AppStrings.save),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.profiles),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddProfileDialog,
          ),
        ],
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
          itemCount: _profiles.length,
          itemBuilder: (context, index) {
            final profile = _profiles[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildProfileCard(profile),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileCard(Profile profile) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(AppTheme.glassOpacity),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              profile.isGlasses ? Icons.glasses : Icons.face,
              color: AppTheme.primaryColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  profile.isGlasses ? AppStrings.glasses : AppStrings.noGlasses,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Edit profile
            },
          ),
        ],
      ),
    );
  }
}
