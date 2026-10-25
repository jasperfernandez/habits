import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/notification_permission_service.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../habits/application/controllers/habits_controller.dart';
import '../../application/settings_controller.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  void _editNameDialog(String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Greeting Name'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Your Name',
            hintText: 'e.g., Jasper',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                ref
                    .read(settingsControllerProvider.notifier)
                    .setUserName(newName);
              }
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleDailyReminders(bool enable) async {
    if (!enable) {
      await ref
          .read(settingsControllerProvider.notifier)
          .setNotificationEnabled(false);
      return;
    }

    final permissionService = ref.read(notificationPermissionServiceProvider);
    final result = await permissionService.requestPermission();

    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);

    if (result == NotificationPermissionResult.granted) {
      await ref
          .read(settingsControllerProvider.notifier)
          .setNotificationEnabled(true);
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Daily reminders enabled!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (result == NotificationPermissionResult.permanentlyDenied) {
      messenger.showSnackBar(
        SnackBar(
          content: const Text(
            'Notification permission is disabled in system settings.',
          ),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Settings',
            onPressed: () => permissionService.openAppSettings(),
          ),
        ),
      );
    } else {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Notification permission was not granted.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final habitsAsync = ref.watch(habitsControllerProvider);
    final userSettings = ref.watch(settingsControllerProvider);
    final totalHabits = habitsAsync.asData?.value.length ?? 0;
    final activeHabits =
        habitsAsync.asData?.value.where((h) => h.archivedAt == null).length ??
        0;
    final displayName = userSettings.userName ?? 'Jasper';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Profile / Greeting Card
          Card(
            color: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppColors.outline),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.primaryContainer,
                    child: const Icon(
                      Icons.person_rounded,
                      size: 32,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Personalized greeting name',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    tooltip: 'Edit name',
                    color: AppColors.textSecondary,
                    onPressed: () => _editNameDialog(displayName),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Preferences section
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'PREFERENCES',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
                letterSpacing: 0.8,
              ),
            ),
          ),
          Card(
            color: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppColors.outline),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text(
                    'Daily Reminders',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  subtitle: const Text(
                    'Get notified to complete your habits',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  value: userSettings.notificationEnabled,
                  activeThumbColor: AppColors.primary,
                  onChanged: _toggleDailyReminders,
                ),
                if (userSettings.notificationEnabled) ...[
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(
                      Icons.schedule_rounded,
                      color: AppColors.primary,
                    ),
                    title: const Text(
                      'Reminder Time',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    subtitle: const Text(
                      'When to receive your daily habit reminder',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    trailing: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: AppColors.surfaceVariant,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: userSettings.reminderTime,
                        );
                        if (picked != null) {
                          await ref
                              .read(settingsControllerProvider.notifier)
                              .setReminderTime(picked);
                        }
                      },
                      child: Text(
                        userSettings.reminderTime.format(context),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ],
                const Divider(height: 1),
                ListTile(
                  title: const Text(
                    'Theme',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    userSettings.themeMode == ThemeMode.dark
                        ? 'Dark mode'
                        : 'Light mode',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  trailing: SegmentedButton<ThemeMode>(
                    segments: const [
                      ButtonSegment(
                        value: ThemeMode.light,
                        icon: Icon(Icons.light_mode_rounded, size: 16),
                        label: Text('Light'),
                      ),
                      ButtonSegment(
                        value: ThemeMode.dark,
                        icon: Icon(Icons.dark_mode_rounded, size: 16),
                        label: Text('Dark'),
                      ),
                    ],
                    selected: {
                      userSettings.themeMode == ThemeMode.dark
                          ? ThemeMode.dark
                          : ThemeMode.light,
                    },
                    onSelectionChanged: (set) {
                      ref
                          .read(settingsControllerProvider.notifier)
                          .setThemeMode(set.first);
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Statistics Overview
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'STATS & OVERVIEW',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
                letterSpacing: 0.8,
              ),
            ),
          ),
          Card(
            color: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppColors.outline),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          '$activeHabits',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Active Habits',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(height: 36, width: 1, color: AppColors.outline),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          '$totalHabits',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Total Tracked',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // About section
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'ABOUT',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
                letterSpacing: 0.8,
              ),
            ),
          ),
          Card(
            color: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppColors.outline),
            ),
            child: const Column(
              children: [
                ListTile(
                  leading: Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.textSecondary,
                  ),
                  title: Text(
                    'Version',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  trailing: Text(
                    '1.0.0',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.spa_outlined, color: AppColors.primary),
                  title: Text(
                    'Habits',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    'Build positive routines, one day at a time.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
