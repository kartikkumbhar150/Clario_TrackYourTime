import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../core/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../models/time_slot.dart';
import '../providers/productivity_provider.dart';

class TimelineScreen extends StatefulWidget {
  const TimelineScreen({super.key});

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  List<String> _generateTimeBlocks() {
    List<String> blocks = [];
    DateTime start = DateTime(2020, 1, 1, 0, 0);
    for (int i = 0; i < 72; i++) {
      String from = DateFormat('HH:mm').format(start);
      start = start.add(const Duration(minutes: 20));
      String to = DateFormat('HH:mm').format(start);
      blocks.add('$from-$to');
    }
    return blocks;
  }

  final List<String> _categories = [
    'Study', 'DSA', 'Work', 'Gym', 'Sleep', 'Social Media', 'Gaming', 'Rest', 'Other'
  ];

  @override
  Widget build(BuildContext context) {
    final blocks = _generateTimeBlocks();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Time Blocks', style: AppTextStyles.h1),
                  const SizedBox(height: 4),
                  Text(
                    '72 slots • 20 min each • Tap to log',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Timeline List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: blocks.length,
                itemBuilder: (context, index) {
                  return _buildTimeBlock(context, blocks[index], index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeBlock(BuildContext context, String timeRange, int index) {
    final now = DateTime.now();
    final hour = int.parse(timeRange.substring(0, 2));
    final minute = int.parse(timeRange.substring(3, 5));
    final isCurrentBlock = now.hour == hour &&
        now.minute >= minute &&
        now.minute < minute + 20;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: () => _showQuickEntrySheet(context, timeRange),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isCurrentBlock
                ? AppColors.primaryBlue.withOpacity(0.06)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isCurrentBlock
                  ? AppColors.primaryBlue.withOpacity(0.3)
                  : AppColors.border.withOpacity(0.5),
            ),
            boxShadow: isCurrentBlock ? AppShadows.cardShadow : AppShadows.softShadow,
          ),
          child: Row(
            children: [
              // Time indicator
              Container(
                width: 4,
                height: 36,
                decoration: BoxDecoration(
                  color: isCurrentBlock
                      ? AppColors.primaryBlue
                      : AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 14),
              // Time range
              SizedBox(
                width: 100,
                child: Text(
                  timeRange,
                  style: AppTextStyles.bodyBold.copyWith(
                    color: isCurrentBlock
                        ? AppColors.primaryBlue
                        : AppColors.textPrimary,
                    fontSize: 14,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              const Spacer(),
              // Action
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isCurrentBlock
                      ? AppColors.primaryBlue.withOpacity(0.1)
                      : AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.add_rounded,
                      size: 16,
                      color: isCurrentBlock
                          ? AppColors.primaryBlue
                          : AppColors.textTertiary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Log',
                      style: AppTextStyles.caption.copyWith(
                        color: isCurrentBlock
                            ? AppColors.primaryBlue
                            : AppColors.textTertiary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showQuickEntrySheet(BuildContext context, String timeRange) {
    String selectedCategory = _categories.first;
    ProductivityType selectedType = ProductivityType.productive;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
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
              // Title
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.schedule_rounded,
                        color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Log $timeRange', style: AppTextStyles.h3),
                      Text('Quick entry • 20 min block',
                          style: AppTextStyles.caption.copyWith(fontSize: 12)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Productivity Type Selection
              Text('HOW WAS THIS TIME?',
                  style: AppTextStyles.label.copyWith(letterSpacing: 1)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ProductivityChip(
                      label: '✨ Productive',
                      color: AppColors.primaryGreen,
                      selected: selectedType == ProductivityType.productive,
                      onTap: () => setSheetState(
                          () => selectedType = ProductivityType.productive),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ProductivityChip(
                      label: '⚡ Neutral',
                      color: AppColors.softOrange,
                      selected: selectedType == ProductivityType.neutral,
                      onTap: () => setSheetState(
                          () => selectedType = ProductivityType.neutral),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ProductivityChip(
                      label: '💤 Wasted',
                      color: AppColors.softPink,
                      selected: selectedType == ProductivityType.wasted,
                      onTap: () => setSheetState(
                          () => selectedType = ProductivityType.wasted),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Category Selection
              Text('CATEGORY',
                  style: AppTextStyles.label.copyWith(letterSpacing: 1)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categories.map((cat) {
                  final isSelected = cat == selectedCategory;
                  return GestureDetector(
                    onTap: () => setSheetState(() => selectedCategory = cat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryBlue.withOpacity(0.1)
                            : AppColors.background,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primaryBlue
                              : AppColors.border,
                        ),
                      ),
                      child: Text(
                        cat,
                        style: AppTextStyles.caption.copyWith(
                          color: isSelected
                              ? AppColors.primaryBlue
                              : AppColors.textSecondary,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 28),

              // Save Button
              GradientButton(
                text: 'Save Time Block',
                onPressed: () {
                  context.read<ProductivityProvider>().addTimeSlot(TimeSlot(
                    date: DateTime.now().toIso8601String(),
                    timeRange: timeRange,
                    taskSelected: selectedCategory,
                    category: selectedCategory,
                    type: selectedType,
                  ));
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$timeRange logged as ${selectedType.name}'),
                      backgroundColor: AppColors.primaryGreen,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
