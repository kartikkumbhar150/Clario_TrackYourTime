import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../core/app_theme.dart';
import '../core/time_utils.dart';
import '../widgets/app_widgets.dart';
import '../services/api_service.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen>
    with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  DateTime _startDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime _endDate = DateTime.now();

  Map<String, dynamic>? _reportData;
  bool _isLoading = false;
  String? _error;

  // Quick range selection
  String _selectedRange = 'Last 7 Days';

  static const List<Color> _categoryColors = [
    Color(0xFF6C8EEF),
    Color(0xFF6BCFA1),
    Color(0xFF9B8FEF),
    Color(0xFFEFAB6B),
    Color(0xFFEF8FA3),
    Color(0xFF5CC2E0),
    Color(0xFFE88FEF),
    Color(0xFFA3D977),
    Color(0xFFEFD36B),
  ];

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
    _fetchReport();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _fetchReport() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _apiService.getReport(_startDate, _endDate);
      setState(() {
        _reportData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  void _setQuickRange(String label) {
    final now = DateTime.now();
    DateTime start;
    DateTime end = now;

    switch (label) {
      case 'Today':
        start = now;
        break;
      case 'Last 7 Days':
        start = now.subtract(const Duration(days: 6));
        break;
      case 'Last 30 Days':
        start = now.subtract(const Duration(days: 29));
        break;
      case 'This Month':
        start = DateTime(now.year, now.month, 1);
        break;
      case 'Last Month':
        final lastMonth = DateTime(now.year, now.month - 1, 1);
        start = lastMonth;
        end = DateTime(now.year, now.month, 0);
        break;
      default:
        start = now.subtract(const Duration(days: 6));
    }

    setState(() {
      _selectedRange = label;
      _startDate = start;
      _endDate = end;
    });
    _fetchReport();
  }

  Future<void> _pickCustomRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryBlue,
              onPrimary: Colors.white,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedRange = 'Custom';
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _fetchReport();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: CustomScrollView(
            slivers: [
              // ─── Header ─────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: AppShadows.softShadow,
                          ),
                          child: const Icon(Icons.arrow_back_rounded,
                              color: AppColors.textPrimary, size: 20),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Productivity Report',
                                style: AppTextStyles.h2),
                            const SizedBox(height: 2),
                            Text(
                              '${_formatDate(_startDate)} — ${_formatDate(_endDate)}',
                              style: AppTextStyles.caption,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 20)),

              // ─── Quick Range Chips ──────────────────
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 42,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    children: [
                      _rangeChip('Today'),
                      _rangeChip('Last 7 Days'),
                      _rangeChip('Last 30 Days'),
                      _rangeChip('This Month'),
                      _rangeChip('Last Month'),
                      _customRangeChip(),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 20)),

              // ─── Content ────────────────────────────
              if (_isLoading)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryBlue,
                    ),
                  ),
                )
              else if (_error != null)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline_rounded,
                            size: 48, color: AppColors.softPink),
                        const SizedBox(height: 12),
                        Text('Failed to load report',
                            style: AppTextStyles.bodyBold),
                        const SizedBox(height: 4),
                        Text(_error!, style: AppTextStyles.caption),
                        const SizedBox(height: 20),
                        GradientButton(
                          text: 'Retry',
                          onPressed: _fetchReport,
                        ),
                      ],
                    ),
                  ),
                )
              else if (_reportData != null)
                ..._buildReportSlivers(),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildReportSlivers() {
    final data = _reportData!;
    final totalMinutes = (data['totalMinutes'] as num?)?.toInt() ?? 0;
    final productiveMinutes =
        (data['productiveMinutes'] as num?)?.toInt() ?? 0;
    final wastedMinutes = (data['wastedMinutes'] as num?)?.toInt() ?? 0;
    final neutralMinutes = (data['neutralMinutes'] as num?)?.toInt() ?? 0;
    final prodPercent =
        (data['productivityPercentage'] as num?)?.toDouble() ?? 0;
    final totalTasks = (data['totalTasks'] as num?)?.toInt() ?? 0;
    final completedTasks = (data['completedTasks'] as num?)?.toInt() ?? 0;
    final categoryBreakdown =
        Map<String, dynamic>.from(data['categoryBreakdown'] ?? {});
    final taskBreakdown =
        Map<String, dynamic>.from(data['taskBreakdown'] ?? {});
    final productivityByCategory =
        Map<String, dynamic>.from(data['productivityByCategory'] ?? {});
    final dailyBreakdown =
        (data['dailyBreakdown'] as List?) ?? [];

    return [
      // ─── Summary Stats Grid ─────────────────
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              Expanded(
                child: StatCard(
                  title: 'Total Time',
                  value: formatTime(totalMinutes),
                  icon: Icons.access_time_rounded,
                  color: AppColors.primaryBlue,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: StatCard(
                  title: 'Productive',
                  value: formatTime(productiveMinutes),
                  subtitle: '${prodPercent.toStringAsFixed(0)}% of time',
                  icon: Icons.trending_up_rounded,
                  color: AppColors.primaryGreen,
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
                  title: 'Wasted',
                  value: formatTime(wastedMinutes),
                  icon: Icons.trending_down_rounded,
                  color: AppColors.softPink,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: StatCard(
                  title: 'Neutral',
                  value: formatTime(neutralMinutes),
                  icon: Icons.remove_circle_outline_rounded,
                  color: AppColors.softOrange,
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
                  title: 'Tasks',
                  value: '$totalTasks',
                  subtitle: '$completedTasks completed',
                  icon: Icons.check_circle_outline_rounded,
                  color: AppColors.primaryPurple,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: StatCard(
                  title: 'Focus Score',
                  value: '${prodPercent.toStringAsFixed(0)}%',
                  icon: Icons.psychology_rounded,
                  color: AppColors.primaryBlue,
                ),
              ),
            ],
          ),
        ),
      ),

      const SliverToBoxAdapter(child: SizedBox(height: 24)),

      // ─── PIE CHART: Productivity Breakdown ──
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
                    Text("Productivity Breakdown",
                        style: AppTextStyles.h3),
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
                  child: totalMinutes == 0
                      ? _emptyPlaceholder(
                          Icons.pie_chart_outline_rounded,
                          'No data in this range')
                      : PieChart(
                          PieChartData(
                            sectionsSpace: 3,
                            centerSpaceRadius: 45,
                            sections: [
                              PieChartSectionData(
                                color: AppColors.primaryGreen,
                                value: productiveMinutes.toDouble(),
                                title: formatTime(productiveMinutes),
                                titleStyle: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white),
                                radius: 30,
                              ),
                              PieChartSectionData(
                                color: AppColors.softOrange,
                                value: neutralMinutes.toDouble(),
                                title: formatTime(neutralMinutes),
                                titleStyle: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white),
                                radius: 26,
                              ),
                              PieChartSectionData(
                                color: AppColors.softPink,
                                value: wastedMinutes.toDouble(),
                                title: formatTime(wastedMinutes),
                                titleStyle: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white),
                                radius: 26,
                              ),
                            ],
                          ),
                        ),
                ),
                const SizedBox(height: 16),
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

      const SliverToBoxAdapter(child: SizedBox(height: 20)),

      // ─── Daily Breakdown Chart ──────────────
      if (dailyBreakdown.isNotEmpty)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.calendar_month_rounded,
                            color: AppColors.primaryBlue, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Text('Daily Overview', style: AppTextStyles.h3),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Productivity by day',
                    style:
                        AppTextStyles.caption.copyWith(fontSize: 12),
                  ),
                  const SizedBox(height: 20),
                  _buildDailyBreakdown(dailyBreakdown),
                ],
              ),
            ),
          ),
        ),

      const SliverToBoxAdapter(child: SizedBox(height: 20)),

      // ─── BAR CHART: Time by Category ────────
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.bar_chart_rounded,
                          color: AppColors.primaryBlue, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Text('Time by Category', style: AppTextStyles.h3),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Total time per category in selected range',
                  style:
                      AppTextStyles.caption.copyWith(fontSize: 12),
                ),
                const SizedBox(height: 20),
                _buildCategoryBars(categoryBreakdown),
              ],
            ),
          ),
        ),
      ),

      const SliverToBoxAdapter(child: SizedBox(height: 20)),

      // ─── BAR CHART: Time per Task ───────────
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryPurple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                          Icons.stacked_bar_chart_rounded,
                          color: AppColors.primaryPurple,
                          size: 18),
                    ),
                    const SizedBox(width: 12),
                    Text('Time per Task', style: AppTextStyles.h3),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'How much time spent on each task',
                  style:
                      AppTextStyles.caption.copyWith(fontSize: 12),
                ),
                const SizedBox(height: 20),
                _buildTaskBars(taskBreakdown),
              ],
            ),
          ),
        ),
      ),

      const SliverToBoxAdapter(child: SizedBox(height: 20)),

      // ─── Productivity per Category ──────────
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.analytics_rounded,
                          color: AppColors.primaryGreen, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Text('Productivity by Category',
                        style: AppTextStyles.h3),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Productive / Neutral / Wasted per category',
                  style:
                      AppTextStyles.caption.copyWith(fontSize: 12),
                ),
                const SizedBox(height: 20),
                _buildProductivityByCategoryChart(
                    productivityByCategory),
                const SizedBox(height: 12),
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

      const SliverToBoxAdapter(child: SizedBox(height: 100)),
    ];
  }

  // ─── Builders ──────────────────────────────────────────

  Widget _buildDailyBreakdown(List<dynamic> dailyData) {
    if (dailyData.isEmpty) {
      return _emptyPlaceholder(
          Icons.calendar_month_rounded, 'No daily data');
    }

    return Column(
      children: dailyData.map<Widget>((day) {
        final date = day['date'] as String;
        final productive =
            (day['productive'] as num?)?.toDouble() ?? 0;
        final neutral = (day['neutral'] as num?)?.toDouble() ?? 0;
        final wasted = (day['wasted'] as num?)?.toDouble() ?? 0;
        final total = (day['total'] as num?)?.toDouble() ?? 0;
        final prodPct =
            (day['productivityPercentage'] as num?)?.toDouble() ?? 0;

        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDateString(date),
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color:
                              AppColors.primaryGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${prodPct.toStringAsFixed(0)}%',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        formatTime(total),
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: SizedBox(
                  height: 10,
                  child: Row(
                    children: [
                      if (productive > 0)
                        Expanded(
                          flex: productive.toInt(),
                          child: Container(
                              color: AppColors.primaryGreen),
                        ),
                      if (neutral > 0)
                        Expanded(
                          flex: neutral.toInt(),
                          child: Container(
                              color: AppColors.softOrange),
                        ),
                      if (wasted > 0)
                        Expanded(
                          flex: wasted.toInt(),
                          child: Container(
                              color: AppColors.softPink),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCategoryBars(Map<String, dynamic> breakdown) {
    if (breakdown.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: _emptyPlaceholder(
            Icons.bar_chart_rounded, 'No category data'),
      );
    }

    final sortedEntries = breakdown.entries.toList()
      ..sort((a, b) => (b.value as num).compareTo(a.value as num));
    final maxMinutes = sortedEntries.isNotEmpty
        ? (sortedEntries.first.value as num).toDouble()
        : 1.0;

    return Column(
      children: sortedEntries.asMap().entries.map((mapEntry) {
        final index = mapEntry.key;
        final entry = mapEntry.value;
        final minutes = (entry.value as num).toDouble();
        final fraction = minutes / maxMinutes;
        final color =
            _categoryColors[index % _categoryColors.length];

        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    entry.key,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      formatTime(minutes),
                      style: AppTextStyles.caption.copyWith(
                        color: color,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: fraction,
                  minHeight: 10,
                  backgroundColor: color.withOpacity(0.08),
                  valueColor:
                      AlwaysStoppedAnimation<Color>(color),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTaskBars(Map<String, dynamic> breakdown) {
    if (breakdown.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: _emptyPlaceholder(
            Icons.stacked_bar_chart_rounded, 'No task data'),
      );
    }

    final sortedEntries = breakdown.entries.toList()
      ..sort((a, b) => (b.value as num).compareTo(a.value as num));
    final maxMinutes = sortedEntries.isNotEmpty
        ? (sortedEntries.first.value as num).toDouble()
        : 1.0;

    return Column(
      children: sortedEntries.asMap().entries.map((mapEntry) {
        final index = mapEntry.key;
        final entry = mapEntry.value;
        final minutes = (entry.value as num).toDouble();
        final fraction = minutes / maxMinutes;
        final color = _categoryColors[
            (index + 3) % _categoryColors.length];

        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      entry.key,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      formatTime(minutes),
                      style: AppTextStyles.caption.copyWith(
                        color: color,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: fraction,
                  minHeight: 10,
                  backgroundColor: color.withOpacity(0.08),
                  valueColor:
                      AlwaysStoppedAnimation<Color>(color),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildProductivityByCategoryChart(
      Map<String, dynamic> productivityByCategory) {
    if (productivityByCategory.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: _emptyPlaceholder(
            Icons.analytics_rounded, 'No breakdown data'),
      );
    }

    return Column(
      children: productivityByCategory.entries.map((entry) {
        final Map<String, dynamic> prodData =
            Map<String, dynamic>.from(entry.value);
        final productive =
            (prodData['productive'] as num?)?.toDouble() ?? 0;
        final neutral =
            (prodData['neutral'] as num?)?.toDouble() ?? 0;
        final wasted =
            (prodData['wasted'] as num?)?.toDouble() ?? 0;
        final totalCat = productive + neutral + wasted;

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    entry.key,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${formatTime(totalCat)} total',
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: SizedBox(
                  height: 12,
                  child: Row(
                    children: [
                      if (productive > 0)
                        Expanded(
                          flex: productive.toInt(),
                          child: Container(
                              color: AppColors.primaryGreen),
                        ),
                      if (neutral > 0)
                        Expanded(
                          flex: neutral.toInt(),
                          child: Container(
                              color: AppColors.softOrange),
                        ),
                      if (wasted > 0)
                        Expanded(
                          flex: wasted.toInt(),
                          child: Container(
                              color: AppColors.softPink),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  if (productive > 0)
                    Text(
                      '${formatTime(productive)} ✨  ',
                      style: AppTextStyles.caption.copyWith(
                          color: AppColors.primaryGreen,
                          fontSize: 10),
                    ),
                  if (neutral > 0)
                    Text(
                      '${formatTime(neutral)} ⚡  ',
                      style: AppTextStyles.caption.copyWith(
                          color: AppColors.softOrange,
                          fontSize: 10),
                    ),
                  if (wasted > 0)
                    Text(
                      '${formatTime(wasted)} 💤  ',
                      style: AppTextStyles.caption.copyWith(
                          color: AppColors.softPink,
                          fontSize: 10),
                    ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ─── UI Helpers ────────────────────────────────────────

  Widget _rangeChip(String label) {
    final selected = _selectedRange == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => _setQuickRange(label),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            gradient: selected ? AppColors.primaryGradient : null,
            color: selected ? null : AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: selected
                ? AppShadows.buttonShadow
                : AppShadows.softShadow,
          ),
          child: Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: selected ? Colors.white : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _customRangeChip() {
    final selected = _selectedRange == 'Custom';
    return GestureDetector(
      onTap: _pickCustomRange,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: selected ? AppColors.warmGradient : null,
          color: selected ? null : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: selected
              ? null
              : Border.all(
                  color: AppColors.softOrange.withOpacity(0.4),
                  width: 1,
                ),
          boxShadow: AppShadows.softShadow,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.date_range_rounded,
                size: 14,
                color: selected
                    ? Colors.white
                    : AppColors.softOrange),
            const SizedBox(width: 6),
            Text(
              'Custom',
              style: AppTextStyles.caption.copyWith(
                color:
                    selected ? Colors.white : AppColors.softOrange,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyPlaceholder(IconData icon, String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: AppColors.textHint),
          const SizedBox(height: 12),
          Text(message, style: AppTextStyles.caption),
        ],
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
        Text(label,
            style: AppTextStyles.caption.copyWith(fontSize: 12)),
      ],
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatDateString(String isoDate) {
    try {
      final parts = isoDate.split('-');
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      final month = int.parse(parts[1]);
      final day = int.parse(parts[2]);
      return '${months[month - 1]} $day';
    } catch (e) {
      return isoDate;
    }
  }
}
