import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_theme.dart';
import '../providers/productivity_provider.dart';
import 'dashboard_screen.dart';
import 'timeline_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    TimelineScreen(),
    ProfileScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Preload data on app launch
    Future.microtask(() {
      context.read<ProductivityProvider>().loadDailyData(DateTime.now());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(0, Icons.dashboard_rounded, 'Dashboard'),
                _navItem(1, Icons.timeline_rounded, 'Timeline'),
                _navItem(2, Icons.person_rounded, 'Profile'),
                _navItem(3, Icons.settings_rounded, 'Settings'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _currentIndex = index);
        // Preload relevant data on tab switch
        final provider = context.read<ProductivityProvider>();
        if (index == 0 && !provider.weeklyTrendLoaded) {
          provider.loadWeeklyTrend();
          provider.loadAIInsights();
        }
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isActive ? 16 : 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primaryBlue.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: isActive ? AppColors.primaryBlue : AppColors.textTertiary,
            ),
            if (isActive) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
