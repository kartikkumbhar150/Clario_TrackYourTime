import 'package:flutter/material.dart';
import '../core/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;
  bool _notifications = true;
  bool _dailyReminder = true;
  bool _weeklyReport = true;
  bool _offlineMode = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text('Settings', style: AppTextStyles.h1),
              const SizedBox(height: 28),

              // General Section
              Text('GENERAL',
                  style: AppTextStyles.label.copyWith(letterSpacing: 1)),
              const SizedBox(height: 12),
              _settingsCard([
                _toggleItem(
                    Icons.dark_mode_rounded, 'Dark Mode', _darkMode, (val) {
                  setState(() => _darkMode = val);
                }),
                _divider(),
                _toggleItem(Icons.wifi_off_rounded, 'Offline Mode', _offlineMode,
                    (val) {
                  setState(() => _offlineMode = val);
                }),
              ]),
              const SizedBox(height: 24),

              // Notifications Section
              Text('NOTIFICATIONS',
                  style: AppTextStyles.label.copyWith(letterSpacing: 1)),
              const SizedBox(height: 12),
              _settingsCard([
                _toggleItem(Icons.notifications_active_rounded,
                    'Push Notifications', _notifications, (val) {
                  setState(() => _notifications = val);
                }),
                _divider(),
                _toggleItem(
                    Icons.alarm_rounded, 'Daily Reminder', _dailyReminder,
                    (val) {
                  setState(() => _dailyReminder = val);
                }),
                _divider(),
                _toggleItem(Icons.summarize_rounded, 'Weekly AI Report',
                    _weeklyReport, (val) {
                  setState(() => _weeklyReport = val);
                }),
              ]),
              const SizedBox(height: 24),

              // Account Section
              Text('ACCOUNT',
                  style: AppTextStyles.label.copyWith(letterSpacing: 1)),
              const SizedBox(height: 12),
              _settingsCard([
                _navItem(Icons.person_outline_rounded, 'Edit Profile', () {}),
                _divider(),
                _navItem(Icons.key_rounded, 'Change Password', () {}),
                _divider(),
                _navItem(Icons.download_rounded, 'Export Data', () {}),
              ]),
              const SizedBox(height: 24),

              // Danger Zone
              Text('DANGER ZONE',
                  style: AppTextStyles.label.copyWith(
                      letterSpacing: 1, color: AppColors.softPink)),
              const SizedBox(height: 12),
              _settingsCard([
                _navItem(Icons.delete_forever_rounded, 'Delete All Data', () {},
                    color: AppColors.softPink),
                _divider(),
                _navItem(Icons.no_accounts_rounded, 'Delete Account', () {},
                    color: AppColors.softPink),
              ]),
              const SizedBox(height: 28),

              // App Info
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.bolt_rounded,
                          color: Colors.white, size: 22),
                    ),
                    const SizedBox(height: 10),
                    Text('Discipline',
                        style: AppTextStyles.bodyBold
                            .copyWith(color: AppColors.textSecondary)),
                    Text('v1.0.0',
                        style: AppTextStyles.caption.copyWith(fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _settingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.softShadow,
      ),
      child: Column(children: children),
    );
  }

  Widget _divider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(color: AppColors.divider, height: 1),
    );
  }

  Widget _toggleItem(
      IconData icon, String title, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primaryBlue, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(child: Text(title, style: AppTextStyles.bodyBold.copyWith(fontSize: 14))),
          Transform.scale(
            scale: 0.8,
            child: Switch.adaptive(
              value: value,
              onChanged: onChanged,
              activeColor: AppColors.primaryBlue,
              activeTrackColor: AppColors.primaryBlue.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String title, VoidCallback onTap,
      {Color? color}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: (color ?? AppColors.primaryBlue).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon,
                  color: color ?? AppColors.primaryBlue, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(title,
                  style: AppTextStyles.bodyBold.copyWith(
                      fontSize: 14, color: color ?? AppColors.textPrimary)),
            ),
            Icon(Icons.chevron_right_rounded,
                color: AppColors.textHint, size: 22),
          ],
        ),
      ),
    );
  }
}
