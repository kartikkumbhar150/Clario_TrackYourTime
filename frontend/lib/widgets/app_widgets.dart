import 'dart:math';
import 'package:flutter/material.dart';
import '../core/app_theme.dart';

// ─── AppCard ─────────────────────────────────────────
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  const AppCard({super.key, required this.child, this.padding, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppShadows.cardShadow,
        ),
        child: child,
      ),
    );
  }
}

// ─── CollapsibleCard ─────────────────────────────────
class CollapsibleCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Widget child;
  final bool initiallyExpanded;

  const CollapsibleCard({
    super.key,
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.child,
    this.initiallyExpanded = true,
  });

  @override
  State<CollapsibleCard> createState() => _CollapsibleCardState();
}

class _CollapsibleCardState extends State<CollapsibleCard>
    with SingleTickerProviderStateMixin {
  late bool _expanded;
  late AnimationController _controller;
  late Animation<double> _rotateAnim;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
      value: _expanded ? 1.0 : 0.0,
    );
    _rotateAnim = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _expanded = !_expanded;
      if (_expanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.cardShadow,
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: _toggle,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: widget.iconColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(widget.icon,
                        color: widget.iconColor, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(widget.title, style: AppTextStyles.h3),
                  ),
                  RotationTransition(
                    turns: _rotateAnim,
                    child: const Icon(Icons.keyboard_arrow_down_rounded,
                        color: AppColors.textTertiary, size: 22),
                  ),
                ],
              ),
            ),
          ),
          ClipRect(
            child: AnimatedCrossFade(
              firstChild: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: widget.child,
              ),
              secondChild: const SizedBox(width: double.infinity),
              crossFadeState: _expanded
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              duration: const Duration(milliseconds: 300),
              sizeCurve: Curves.easeInOut,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── GradientButton ──────────────────────────────────
class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final LinearGradient? gradient;

  const GradientButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: gradient ?? AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppShadows.buttonShadow,
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 24, height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2.5))
              : Text(text, style: AppTextStyles.button),
        ),
      ),
    );
  }
}

// ─── AppTextField ────────────────────────────────────
class AppTextField extends StatelessWidget {
  final String hint;
  final IconData? prefixIcon;
  final bool obscureText;
  final TextEditingController? controller;
  final Widget? suffixIcon;

  const AppTextField({
    super.key,
    required this.hint,
    this.prefixIcon,
    this.obscureText = false,
    this.controller,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: AppTextStyles.bodyBold,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: AppColors.textTertiary, size: 20)
            : null,
        suffixIcon: suffixIcon,
      ),
    );
  }
}

// ─── StatCard ────────────────────────────────────────
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color color;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
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
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(value, style: AppTextStyles.h2.copyWith(fontSize: 24)),
          const SizedBox(height: 4),
          Text(title, style: AppTextStyles.caption),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(subtitle!, style: AppTextStyles.caption.copyWith(
              color: AppColors.primaryGreen, fontSize: 11)),
          ],
        ],
      ),
    );
  }
}

// ─── ProductivityChip ────────────────────────────────
class ProductivityChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const ProductivityChip({
    super.key,
    required this.label,
    required this.color,
    this.selected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.15) : AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? color : AppColors.border,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: selected ? color : AppColors.textSecondary,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// ─── AnimatedScoreRing ───────────────────────────────
class AnimatedScoreRing extends StatefulWidget {
  final double score; // 0-100
  final double size;
  final double strokeWidth;

  const AnimatedScoreRing({
    super.key,
    required this.score,
    this.size = 140,
    this.strokeWidth = 12,
  });

  @override
  State<AnimatedScoreRing> createState() => _AnimatedScoreRingState();
}

class _AnimatedScoreRingState extends State<AnimatedScoreRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: widget.score / 100)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedScoreRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.score != widget.score) {
      _animation = Tween<double>(begin: _animation.value, end: widget.score / 100)
          .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = AppColors.productivityIndexColor(widget.score);
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return SizedBox(
          width: widget.size, height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _RingPainter(
                  progress: _animation.value,
                  color: color,
                  strokeWidth: widget.strokeWidth,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${(_animation.value * 100).round()}',
                    style: AppTextStyles.metric.copyWith(
                      color: color, fontSize: widget.size * 0.26),
                  ),
                  Text('Score',
                    style: AppTextStyles.caption.copyWith(fontSize: 11)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  _RingPainter({required this.progress, required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background ring
    final bgPaint = Paint()
      ..color = AppColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    // Progress ring
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2,
        2 * pi * progress,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}

// ─── TaskListItem ────────────────────────────────────
class TaskListItem extends StatelessWidget {
  final String taskName;
  final bool isCompleted;
  final VoidCallback? onToggle;
  final bool isLocked;

  const TaskListItem({
    super.key,
    required this.taskName,
    required this.isCompleted,
    this.onToggle,
    this.isLocked = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: onToggle,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isCompleted
                ? AppColors.primaryGreen.withValues(alpha: 0.06)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isCompleted
                  ? AppColors.primaryGreen.withValues(alpha: 0.3)
                  : AppColors.border,
            ),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 24, height: 24,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppColors.primaryGreen
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(
                    color: isCompleted
                        ? AppColors.primaryGreen
                        : AppColors.border,
                    width: 2,
                  ),
                ),
                child: isCompleted
                    ? const Icon(Icons.check_rounded,
                        size: 16, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  taskName,
                  style: AppTextStyles.bodyBold.copyWith(
                    fontSize: 14,
                    decoration: isCompleted
                        ? TextDecoration.lineThrough
                        : null,
                    color: isCompleted
                        ? AppColors.textTertiary
                        : AppColors.textPrimary,
                  ),
                ),
              ),
              if (isLocked)
                Icon(Icons.lock_outline_rounded,
                    size: 16, color: AppColors.textHint),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── SummaryPill ─────────────────────────────────────
class SummaryPill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const SummaryPill({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: AppTextStyles.bodyBold.copyWith(
                fontSize: 13, color: color)),
              Text(label, style: AppTextStyles.caption.copyWith(
                fontSize: 9, color: color.withValues(alpha: 0.7))),
            ],
          ),
        ],
      ),
    );
  }
}
