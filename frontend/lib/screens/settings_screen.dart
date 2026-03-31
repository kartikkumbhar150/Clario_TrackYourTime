import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_theme.dart';
import '../providers/productivity_provider.dart';
import '../services/api_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _categoryController = TextEditingController();
  
  bool _darkMode = false;
  bool _notifications = true;
  bool _dailyReminder = true;
  bool _weeklyReport = true;

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

              // Time Slot Categories Section
              Text('TIME SLOT CATEGORIES',
                  style: AppTextStyles.label.copyWith(letterSpacing: 1)),
              const SizedBox(height: 12),
              _buildCategoriesSection(context),
              const SizedBox(height: 24),

              // Account Section
              Text('ACCOUNT',
                  style: AppTextStyles.label.copyWith(letterSpacing: 1)),
              const SizedBox(height: 12),
              _settingsCard([
                _navItem(Icons.logout_rounded, 'Sign Out', () async {
                  final apiService = ApiService();
                  await apiService.logout();
                  if (context.mounted) {
                    context.read<ProductivityProvider>().clearData();
                    Navigator.pushNamedAndRemoveUntil(
                      context, '/login', (route) => false,
                    );
                  }
                }),
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

  Widget _buildCategoriesSection(BuildContext context) {
    final provider = context.watch<ProductivityProvider>();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: provider.categories.map((cat) {
              return Chip(
                label: Text(cat, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                side: BorderSide.none,
                deleteIcon: Icon(Icons.close_rounded, size: 16, color: AppColors.softPink),
                onDeleted: () {
                  provider.removeCategory(cat);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _categoryController,
                  style: AppTextStyles.caption.copyWith(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'New category...',
                    hintStyle: AppTextStyles.caption.copyWith(color: AppColors.textHint),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  if (_categoryController.text.trim().isNotEmpty) {
                    provider.addCategory(_categoryController.text.trim());
                    _categoryController.clear();
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
