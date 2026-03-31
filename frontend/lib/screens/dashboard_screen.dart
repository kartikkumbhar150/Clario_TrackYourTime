import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../core/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../providers/productivity_provider.dart';
import 'timeline_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  final _taskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();

    Future.microtask(() =>
      context.read<ProductivityProvider>().loadDailyData(DateTime.now()),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    _taskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Consumer<ProductivityProvider>(
            builder: (context, provider, _) {
              final totalSlots = provider.slots.length;
              final productiveSlots = provider.slots
                  .where((s) => s.type.toString().endsWith('productive'))
                  .length;
              final wastedSlots = provider.slots
                  .where((s) => s.type.toString().endsWith('wasted'))
                  .length;
              final neutralSlots = totalSlots - productiveSlots - wastedSlots;
              final prodPercent =
                  totalSlots > 0 ? (productiveSlots / totalSlots) * 100 : 0.0;

              return CustomScrollView(
                slivers: [
                  // Header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Good ${_getGreeting()}',
                                style: AppTextStyles.caption.copyWith(fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                              Text('Dashboard', style: AppTextStyles.h1),
                            ],
                          ),
                          // Date badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: AppShadows.buttonShadow,
                            ),
                            child: Text(
                              _formattedDate(),
                              style: AppTextStyles.caption.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 24)),

                  // Stats Grid
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        children: [
                          Expanded(
                            child: StatCard(
                              title: 'Productive',
                              value: '${(productiveSlots * 20)}m',
                              subtitle: '${prodPercent.toStringAsFixed(0)}% of time',
                              icon: Icons.trending_up_rounded,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: StatCard(
                              title: 'Wasted',
                              value: '${(wastedSlots * 20)}m',
                              icon: Icons.trending_down_rounded,
                              color: AppColors.softPink,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 14)),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        children: [
                          Expanded(
                            child: StatCard(
                              title: 'Tracked Slots',
                              value: '$totalSlots/72',
                              icon: Icons.grid_view_rounded,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: StatCard(
                              title: 'Tasks',
                              value: '${provider.tasks.length}',
                              subtitle:
                                  '${provider.tasks.where((t) => t.isCompleted).length} done',
                              icon: Icons.check_circle_outline_rounded,
                              color: AppColors.primaryPurple,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 28)),

                  // Productivity Ring
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Today\'s Focus', style: AppTextStyles.h3),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryGreen.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${prodPercent.toStringAsFixed(0)}%',
                                    style: AppTextStyles.bodyBold.copyWith(
                                      color: AppColors.primaryGreen,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              height: 180,
                              child: totalSlots == 0
                                  ? Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.pie_chart_outline_rounded,
                                              size: 48,
                                              color: AppColors.textHint),
                                          const SizedBox(height: 12),
                                          Text('No data yet',
                                              style: AppTextStyles.caption),
                                          Text('Start tracking your time blocks',
                                              style: AppTextStyles.caption
                                                  .copyWith(fontSize: 12)),
                                        ],
                                      ),
                                    )
                                  : PieChart(
                                      PieChartData(
                                        sectionsSpace: 3,
                                        centerSpaceRadius: 45,
                                        sections: [
                                          PieChartSectionData(
                                            color: AppColors.primaryGreen,
                                            value: productiveSlots.toDouble(),
                                            title: '',
                                            radius: 28,
                                          ),
                                          PieChartSectionData(
                                            color: AppColors.softOrange,
                                            value: neutralSlots.toDouble(),
                                            title: '',
                                            radius: 24,
                                          ),
                                          PieChartSectionData(
                                            color: AppColors.softPink,
                                            value: wastedSlots.toDouble(),
                                            title: '',
                                            radius: 24,
                                          ),
                                        ],
                                      ),
                                    ),
                            ),
                            const SizedBox(height: 16),
                            // Legend
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _legendItem('Productive', AppColors.primaryGreen),
                                _legendItem('Neutral', AppColors.softOrange),
                                _legendItem('Wasted', AppColors.softPink),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 28)),

                  // Tasks Section
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Today\'s Tasks', style: AppTextStyles.h3),
                          GestureDetector(
                            onTap: () => _showAddTaskSheet(context),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.add_rounded,
                                  color: Colors.white, size: 20),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 14)),

                  // Task List
                  provider.tasks.isEmpty
                      ? SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: AppCard(
                              child: Center(
                                child: Column(
                                  children: [
                                    Icon(Icons.checklist_rounded,
                                        size: 40,
                                        color: AppColors.textHint),
                                    const SizedBox(height: 12),
                                    Text('No tasks yet',
                                        style: AppTextStyles.bodyBold),
                                    const SizedBox(height: 4),
                                    Text('Tap + to add your first task',
                                        style: AppTextStyles.caption),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                      : SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final task = provider.tasks[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 4),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 14),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: AppShadows.softShadow,
                                    border: Border.all(
                                      color: task.isCompleted
                                          ? AppColors.primaryGreen.withOpacity(0.3)
                                          : AppColors.border,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          if (!task.isCompleted) {
                                            provider.completeTask(task);
                                          }
                                        },
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 200),
                                          width: 26,
                                          height: 26,
                                          decoration: BoxDecoration(
                                            gradient: task.isCompleted
                                                ? AppColors.greenGradient
                                                : null,
                                            color: task.isCompleted
                                                ? null
                                                : Colors.transparent,
                                            borderRadius: BorderRadius.circular(8),
                                            border: task.isCompleted
                                                ? null
                                                : Border.all(
                                                    color: AppColors.border,
                                                    width: 1.5),
                                          ),
                                          child: task.isCompleted
                                              ? const Icon(Icons.check,
                                                  size: 16, color: Colors.white)
                                              : null,
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Text(
                                          task.taskName,
                                          style: AppTextStyles.bodyBold.copyWith(
                                            decoration: task.isCompleted
                                                ? TextDecoration.lineThrough
                                                : null,
                                            color: task.isCompleted
                                                ? AppColors.textTertiary
                                                : AppColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                      // Lock icon - immutable!
                                      Icon(Icons.lock_outline_rounded,
                                          size: 16,
                                          color: AppColors.textHint),
                                    ],
                                  ),
                                ),
                              );
                            },
                            childCount: provider.tasks.length,
                          ),
                        ),

                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: AppTextStyles.caption.copyWith(fontSize: 12)),
      ],
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning ☀️';
    if (hour < 17) return 'Afternoon 🌤️';
    return 'Evening 🌙';
  }

  String _formattedDate() {
    final now = DateTime.now();
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[now.month - 1]} ${now.day}';
  }

  void _showAddTaskSheet(BuildContext context) {
    _taskController.clear();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.fromLTRB(
            24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Add New Task', style: AppTextStyles.h3),
            const SizedBox(height: 6),
            Text(
              'Once added, tasks cannot be edited or deleted',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.softPink,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 20),
            AppTextField(
              hint: 'What do you need to do?',
              prefixIcon: Icons.edit_outlined,
              controller: _taskController,
            ),
            const SizedBox(height: 20),
            GradientButton(
              text: 'Add Task (Immutable)',
              onPressed: () {
                if (_taskController.text.isNotEmpty) {
                  context
                      .read<ProductivityProvider>()
                      .addTask(_taskController.text, DateTime.now());
                  Navigator.pop(ctx);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
