import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../core/app_theme.dart';
import '../core/time_utils.dart';
import '../providers/productivity_provider.dart';
import '../widgets/app_widgets.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
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
    _fadeAnim =
        CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();

    Future.microtask(() {
      final provider = context.read<ProductivityProvider>();
      provider.loadDailyData(DateTime.now());
      provider.loadWeeklyTrend();
      provider.loadAIInsights();
    });
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
        child: Consumer<ProductivityProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading && provider.totalMinutes == 0) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primaryBlue));
            }

            return FadeTransition(
              opacity: _fadeAnim,
              child: RefreshIndicator(
                color: AppColors.primaryBlue,
                onRefresh: () async {
                  await provider.loadDailyData(DateTime.now());
                  await provider.loadWeeklyTrend();
                },
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                  children: [
                    // Header
                    _buildHeader(),
                    const SizedBox(height: 20),

                    // Productivity Index + Quick Stats
                    _buildProductivitySection(provider),
                    const SizedBox(height: 16),

                    // Quick Stats Row
                    _buildQuickStats(provider),
                    const SizedBox(height: 20),

                    // Task Checklist
                    _buildTaskChecklist(provider),
                    const SizedBox(height: 16),

                    // Donut Chart — Category Time
                    CollapsibleCard(
                      title: 'Time by Category',
                      icon: Icons.donut_large_rounded,
                      iconColor: AppColors.primaryPurple,
                      child: _buildDonutChart(provider),
                    ),
                    const SizedBox(height: 16),

                    // Pie Chart — Productive vs Unproductive
                    CollapsibleCard(
                      title: 'Productivity Split',
                      icon: Icons.pie_chart_rounded,
                      iconColor: AppColors.primaryGreen,
                      child: _buildProductivityPie(provider),
                    ),
                    const SizedBox(height: 16),

                    // Bar Chart — Tasks Completed vs Missed
                    if (provider.weeklyTrendLoaded)
                      CollapsibleCard(
                        title: 'Tasks Overview',
                        icon: Icons.bar_chart_rounded,
                        iconColor: AppColors.softOrange,
                        child: _buildTasksBarChart(provider),
                      ),
                    if (provider.weeklyTrendLoaded) const SizedBox(height: 16),

                    // Line Chart — Productivity Trend
                    if (provider.weeklyTrendLoaded)
                      CollapsibleCard(
                        title: 'Weekly Trend',
                        icon: Icons.show_chart_rounded,
                        iconColor: AppColors.primaryBlue,
                        child: _buildProductivityLineChart(provider),
                      ),
                    if (provider.weeklyTrendLoaded) const SizedBox(height: 16),

                    // Area Chart — Cumulative Focus
                    if (provider.weeklyTrendLoaded &&
                        provider.cumulativeFocus.isNotEmpty)
                      CollapsibleCard(
                        title: 'Cumulative Focus',
                        icon: Icons.stacked_line_chart_rounded,
                        iconColor: AppColors.softTeal,
                        child: _buildCumulativeAreaChart(provider),
                      ),
                    if (provider.weeklyTrendLoaded) const SizedBox(height: 16),

                    // Scatter Plot — Time vs Completion
                    if (provider.categoryBreakdown.isNotEmpty)
                      CollapsibleCard(
                        title: 'Time vs Productivity',
                        icon: Icons.scatter_plot_rounded,
                        iconColor: AppColors.softLavender,
                        child: _buildScatterPlot(provider),
                      ),
                    if (provider.categoryBreakdown.isNotEmpty)
                      const SizedBox(height: 16),

                    // AI Insights
                    if (provider.aiInsightsLoaded)
                      _buildAIInsightsCard(provider),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final now = DateTime.now();
    final greeting = now.hour < 12
        ? 'Good Morning'
        : now.hour < 17
            ? 'Good Afternoon'
            : 'Good Evening';

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(greeting,
                  style: AppTextStyles.caption.copyWith(fontSize: 14)),
              const SizedBox(height: 4),
              Text('Dashboard', style: AppTextStyles.h1),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: AppShadows.softShadow,
          ),
          child: const Icon(Icons.today_rounded,
              color: AppColors.primaryBlue, size: 22),
        ),
      ],
    );
  }

  Widget _buildProductivitySection(ProductivityProvider provider) {
    return AppCard(
      child: Row(
        children: [
          AnimatedScoreRing(
            score: provider.productivityIndex.toDouble(),
            size: 120,
            strokeWidth: 10,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Productivity Index',
                    style: AppTextStyles.label.copyWith(letterSpacing: 0.5)),
                const SizedBox(height: 4),
                Text(
                  _getScoreLabel(provider.productivityIndex),
                  style: AppTextStyles.h3.copyWith(
                    color: AppColors.productivityIndexColor(
                        provider.productivityIndex.toDouble()),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${provider.totalMinutes > 0 ? "${formatTime(provider.totalMinutes)} tracked" : "No time tracked"}',
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: 2),
                Text(
                  '${provider.completedTasks}/${provider.totalTasks} tasks done',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getScoreLabel(int score) {
    if (score >= 80) return 'Excellent! 🔥';
    if (score >= 60) return 'Great Work! 💪';
    if (score >= 40) return 'Keep Going! ⚡';
    if (score >= 20) return 'Needs Focus 🎯';
    return 'Get Started! 🚀';
  }

  Widget _buildQuickStats(ProductivityProvider provider) {
    return Row(
      children: [
        Expanded(
          child: _miniStat('Focused',
              formatTime(provider.productiveMinutes), AppColors.productive),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _miniStat('Wasted',
              formatTime(provider.wastedMinutes), AppColors.wasted),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _miniStat('Neutral',
              formatTime(provider.neutralMinutes), AppColors.neutral),
        ),
      ],
    );
  }

  Widget _miniStat(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppShadows.softShadow,
      ),
      child: Column(
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              label == 'Focused'
                  ? Icons.bolt_rounded
                  : label == 'Wasted'
                      ? Icons.warning_amber_rounded
                      : Icons.balance_rounded,
              color: color,
              size: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(value,
              style: AppTextStyles.bodyBold.copyWith(fontSize: 16, color: color)),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.caption.copyWith(fontSize: 10)),
        ],
      ),
    );
  }

  // ─── Task Checklist ────────────────────────────────────
  Widget _buildTaskChecklist(ProductivityProvider provider) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.checklist_rounded,
                    color: AppColors.primaryBlue, size: 18),
              ),
              const SizedBox(width: 12),
              Text("Today's Tasks", style: AppTextStyles.h3),
              const Spacer(),
              if (provider.tasks.isNotEmpty)
                Text(
                  '${provider.tasks.where((t) => t.isCompleted).length}/${provider.tasks.length}',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primaryGreen, fontWeight: FontWeight.w600),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Task list
          ...provider.tasks.map((task) => TaskListItem(
                taskName: task.taskName,
                isCompleted: task.isCompleted,
                isLocked: true,
                onToggle: task.isCompleted
                    ? null
                    : () => provider.completeTask(task),
              )),

          // Add task
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _taskController,
                  style: AppTextStyles.bodyBold.copyWith(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Add a task (immutable after creation)...',
                    hintStyle: AppTextStyles.caption.copyWith(
                        color: AppColors.textHint, fontSize: 12),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: const Icon(Icons.lock_outline_rounded,
                        size: 14, color: AppColors.textHint),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  if (_taskController.text.trim().isNotEmpty) {
                    provider.addTask(
                        _taskController.text.trim(), DateTime.now());
                    _taskController.clear();
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
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
        ],
      ),
    );
  }

  // ─── Donut Chart: Category Time ────────────────────────
  Widget _buildDonutChart(ProductivityProvider provider) {
    final data = provider.categoryBreakdown;
    if (data.isEmpty) {
      return _emptyChartPlaceholder('Track time to see category breakdown');
    }

    final entries = data.entries.toList();
    final total = entries.fold<double>(0, (s, e) => s + (e.value as num));

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sectionsSpace: 3,
              centerSpaceRadius: 50,
              sections: entries.asMap().entries.map((entry) {
                final i = entry.key;
                final e = entry.value;
                final value = (e.value as num).toDouble();
                final color = AppColors.categoryColor(e.key, i);
                return PieChartSectionData(
                  value: value,
                  color: color,
                  radius: 35,
                  showTitle: false,
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12, runSpacing: 6,
          children: entries.asMap().entries.map((entry) {
            final i = entry.key;
            final e = entry.value;
            final pct = total > 0
                ? ((e.value as num) / total * 100).toStringAsFixed(0)
                : '0';
            return _legendItem(e.key, AppColors.categoryColor(e.key, i),
                '${formatTime((e.value as num).toInt())} ($pct%)');
          }).toList(),
        ),
      ],
    );
  }

  // ─── Pie Chart: Productive vs Unproductive ─────────────
  Widget _buildProductivityPie(ProductivityProvider provider) {
    final prod = provider.productiveMinutes.toDouble();
    final neutral = provider.neutralMinutes.toDouble();
    final wasted = provider.wastedMinutes.toDouble();
    final total = prod + neutral + wasted;

    if (total == 0) {
      return _emptyChartPlaceholder('Track time to see productivity split');
    }

    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PieChart(
            PieChartData(
              sectionsSpace: 3,
              centerSpaceRadius: 40,
              sections: [
                PieChartSectionData(
                    value: prod, color: AppColors.productive,
                    radius: 30, showTitle: false),
                PieChartSectionData(
                    value: neutral, color: AppColors.neutral,
                    radius: 30, showTitle: false),
                PieChartSectionData(
                    value: wasted, color: AppColors.wasted,
                    radius: 30, showTitle: false),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _legendItem('Productive', AppColors.productive,
                '${(prod / total * 100).toStringAsFixed(0)}%'),
            const SizedBox(width: 16),
            _legendItem('Neutral', AppColors.neutral,
                '${(neutral / total * 100).toStringAsFixed(0)}%'),
            const SizedBox(width: 16),
            _legendItem('Wasted', AppColors.wasted,
                '${(wasted / total * 100).toStringAsFixed(0)}%'),
          ],
        ),
      ],
    );
  }

  // ─── Bar Chart: Tasks Completed vs Missed ──────────────
  Widget _buildTasksBarChart(ProductivityProvider provider) {
    final trend = provider.weeklyTrend;
    if (trend.isEmpty) {
      return _emptyChartPlaceholder('Weekly data will appear here');
    }

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final day = trend[group.x.toInt()];
                final label = rodIndex == 0 ? 'Done' : 'Missed';
                return BarTooltipItem(
                  '$label: ${rod.toY.toInt()}',
                  AppTextStyles.caption.copyWith(
                      color: Colors.white, fontSize: 11),
                );
              },
            ),
          ),
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i < 0 || i >= trend.length) {
                    return const Text('');
                  }
                  final date = trend[i]['date'] as String;
                  final dayNames = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
                  final dt = DateTime.tryParse(date);
                  return Text(
                    dt != null ? dayNames[dt.weekday % 7] : '',
                    style: AppTextStyles.caption.copyWith(fontSize: 10),
                  );
                },
              ),
            ),
          ),
          barGroups: trend.asMap().entries.map((entry) {
            final i = entry.key;
            final day = entry.value;
            return BarChartGroupData(x: i, barRods: [
              BarChartRodData(
                toY: (day['tasksCompleted'] as num?)?.toDouble() ?? 0,
                color: AppColors.primaryGreen,
                width: 10,
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4)),
              ),
              BarChartRodData(
                toY: (day['tasksMissed'] as num?)?.toDouble() ?? 0,
                color: AppColors.wasted,
                width: 10,
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4)),
              ),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  // ─── Line Chart: Productivity Trend ────────────────────
  Widget _buildProductivityLineChart(ProductivityProvider provider) {
    final trend = provider.weeklyTrend;
    if (trend.isEmpty) {
      return _emptyChartPlaceholder('Weekly data will appear here');
    }

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 25,
            getDrawingHorizontalLine: (value) => FlLine(
              color: AppColors.border,
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                getTitlesWidget: (value, meta) => Text(
                  '${value.toInt()}',
                  style: AppTextStyles.caption.copyWith(fontSize: 10),
                ),
              ),
            ),
            rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i < 0 || i >= trend.length) return const Text('');
                  final date = trend[i]['date'] as String;
                  final dt = DateTime.tryParse(date);
                  final dayNames = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
                  return Text(
                    dt != null ? dayNames[dt.weekday % 7] : '',
                    style: AppTextStyles.caption.copyWith(fontSize: 10),
                  );
                },
              ),
            ),
          ),
          minY: 0, maxY: 100,
          lineBarsData: [
            LineChartBarData(
              spots: trend.asMap().entries.map((e) {
                return FlSpot(
                  e.key.toDouble(),
                  (e.value['productivityIndex'] as num?)?.toDouble() ?? 0,
                );
              }).toList(),
              color: AppColors.primaryBlue,
              barWidth: 3,
              isCurved: true,
              curveSmoothness: 0.3,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, p, bar, i) => FlDotCirclePainter(
                  radius: 4,
                  color: AppColors.primaryBlue,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.primaryBlue.withValues(alpha: 0.08),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Area Chart: Cumulative Focus ──────────────────────
  Widget _buildCumulativeAreaChart(ProductivityProvider provider) {
    final data = provider.cumulativeFocus;
    if (data.isEmpty) {
      return _emptyChartPlaceholder('Focus data will appear here');
    }

    final maxY = data.fold<double>(
        0, (m, d) => (d['cumulativeMinutes'] as num).toDouble() > m
            ? (d['cumulativeMinutes'] as num).toDouble()
            : m);

    return SizedBox(
      height: 180,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) => Text(
                  formatTime(value.toInt()),
                  style: AppTextStyles.caption.copyWith(fontSize: 9),
                ),
              ),
            ),
            rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i < 0 || i >= data.length) return const Text('');
                  final date = data[i]['date'] as String;
                  return Text(
                    date.substring(8, 10),
                    style: AppTextStyles.caption.copyWith(fontSize: 10),
                  );
                },
              ),
            ),
          ),
          minY: 0,
          maxY: maxY > 0 ? maxY * 1.2 : 100,
          lineBarsData: [
            LineChartBarData(
              spots: data.asMap().entries.map((e) {
                return FlSpot(
                  e.key.toDouble(),
                  (e.value['cumulativeMinutes'] as num).toDouble(),
                );
              }).toList(),
              color: AppColors.softTeal,
              barWidth: 3,
              isCurved: true,
              curveSmoothness: 0.3,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.softTeal.withValues(alpha: 0.3),
                    AppColors.softTeal.withValues(alpha: 0.02),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Scatter Plot: Time vs Productivity ────────────────
  Widget _buildScatterPlot(ProductivityProvider provider) {
    final catBreakdown = provider.categoryBreakdown;
    final prodByCat = provider.productivityByCategory;

    if (catBreakdown.isEmpty) {
      return _emptyChartPlaceholder('Category data will appear here');
    }

    final spots = <ScatterSpot>[];
    final categories = catBreakdown.keys.toList();

    for (int i = 0; i < categories.length; i++) {
      final cat = categories[i];
      final totalMin = (catBreakdown[cat] as num?)?.toDouble() ?? 0;
      final prodData = prodByCat[cat];
      double prodRate = 0;
      if (prodData != null) {
        final prodMin = (prodData['productive'] as num?)?.toDouble() ?? 0;
        prodRate = totalMin > 0 ? (prodMin / totalMin * 100) : 0;
      }
      spots.add(ScatterSpot(
        totalMin,
        prodRate,
        dotPainter: FlDotCirclePainter(
          radius: 8,
          color: AppColors.categoryColor(cat, i).withValues(alpha: 0.8),
          strokeWidth: 2,
          strokeColor: AppColors.categoryColor(cat, i),
        ),
      ));
    }

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: ScatterChart(
            ScatterChartData(
              scatterSpots: spots,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 25,
                getDrawingHorizontalLine: (value) =>
                    FlLine(color: AppColors.border, strokeWidth: 1),
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (v, m) => Text('${v.toInt()}%',
                        style: AppTextStyles.caption.copyWith(fontSize: 9)),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (v, m) => Text('${v.toInt()}m',
                        style: AppTextStyles.caption.copyWith(fontSize: 9)),
                  ),
                ),
                rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
              ),
              minY: 0, maxY: 100,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text('X = Time spent  •  Y = Productivity %',
            style: AppTextStyles.caption.copyWith(fontSize: 10)),
      ],
    );
  }

  // ─── AI Insights Card ─────────────────────────────────
  Widget _buildAIInsightsCard(ProductivityProvider provider) {
    final data = provider.aiInsightsData;
    final insights = List<Map<String, dynamic>>.from(data['insights'] ?? []);
    final summary = data['summary'] as String? ?? '';

    return CollapsibleCard(
      title: 'AI Insights',
      icon: Icons.auto_awesome_rounded,
      iconColor: AppColors.softYellow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (summary.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(summary, style: AppTextStyles.body.copyWith(
                fontSize: 13, height: 1.4)),
            ),
            const SizedBox(height: 12),
          ],
          ...insights.map((insight) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(insight['icon'] ?? '💡',
                      style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      insight['text'] ?? '',
                      style: AppTextStyles.body.copyWith(
                          fontSize: 13, height: 1.4),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ─── Helpers ───────────────────────────────────────────

  Widget _legendItem(String label, Color color, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8, height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        Text('$label $value',
            style: AppTextStyles.caption.copyWith(fontSize: 10)),
      ],
    );
  }

  Widget _emptyChartPlaceholder(String text) {
    return Container(
      height: 120,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.analytics_outlined,
              size: 32, color: AppColors.textHint),
          const SizedBox(height: 8),
          Text(text, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}
