import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../widgets/app_widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 16),
              // Header
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Profile', style: AppTextStyles.h1),
              ),
              const SizedBox(height: 32),

              // Avatar & Info
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: AppShadows.buttonShadow,
                ),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                      ),
                      child: const Icon(Icons.person_rounded, size: 40, color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Kartik',
                      style: AppTextStyles.h2.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'kartik@example.com',
                      style: AppTextStyles.body.copyWith(
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Stats row
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _profileStat('7', 'Day Streak 🔥'),
                          Container(width: 1, height: 30, color: Colors.white24),
                          _profileStat('85%', 'Avg Focus'),
                          Container(width: 1, height: 30, color: Colors.white24),
                          _profileStat('Lv.3', 'Rank'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Menu Items
              _menuItem(Icons.emoji_events_rounded, 'Achievements & Badges',
                  AppColors.softOrange, () {}),
              const SizedBox(height: 10),
              _menuItem(Icons.bar_chart_rounded, 'Weekly Report',
                  AppColors.primaryBlue, () {}),
              const SizedBox(height: 10),
              _menuItem(Icons.category_rounded, 'Manage Categories',
                  AppColors.primaryPurple, () {}),
              const SizedBox(height: 10),
              _menuItem(Icons.psychology_rounded, 'AI Insights',
                  AppColors.primaryGreen, () {}),
              const SizedBox(height: 10),
              _menuItem(Icons.cloud_sync_rounded, 'Sync & Backup',
                  AppColors.primaryBlue, () {}),
              const SizedBox(height: 10),
              _menuItem(Icons.logout_rounded, 'Sign Out',
                  AppColors.softPink, () {}),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _profileStat(String value, String label) {
    return Column(
      children: [
        Text(value,
            style: AppTextStyles.h3.copyWith(color: Colors.white, fontSize: 16)),
        const SizedBox(height: 2),
        Text(label,
            style: AppTextStyles.caption.copyWith(
                color: Colors.white70, fontSize: 11)),
      ],
    );
  }

  Widget _menuItem(
      IconData icon, String title, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: AppShadows.softShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(title, style: AppTextStyles.bodyBold),
            ),
            Icon(Icons.chevron_right_rounded,
                color: AppColors.textHint, size: 22),
          ],
        ),
      ),
    );
  }
}
