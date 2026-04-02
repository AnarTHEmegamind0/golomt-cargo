import 'package:flutter/material.dart';

/// Timeline step data
class TimelineStepData {
  const TimelineStepData({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.dateTime,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final DateTime? dateTime;
}

/// Vertical process timeline
class ProcessTimeline extends StatelessWidget {
  const ProcessTimeline({
    super.key,
    required this.steps,
    required this.currentStep,
    this.completedColor,
    this.activeColor,
    this.pendingColor,
  });

  final List<TimelineStepData> steps;
  final int currentStep;
  final Color? completedColor;
  final Color? activeColor;
  final Color? pendingColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final completed = completedColor ?? const Color(0xFF10B981);
    final active = activeColor ?? primaryColor;
    final pending =
        pendingColor ??
        (isDark ? const Color(0xFF4B5563) : const Color(0xFFD1D5DB));

    return Column(
      children: List.generate(steps.length, (index) {
        final step = steps[index];
        final isCompleted = index < currentStep;
        final isActive = index == currentStep;
        final isLast = index == steps.length - 1;

        Color stepColor;
        if (isCompleted) {
          stepColor = completed;
        } else if (isActive) {
          stepColor = active;
        } else {
          stepColor = pending;
        }

        return _TimelineStep(
          step: step,
          stepColor: stepColor,
          isCompleted: isCompleted,
          isActive: isActive,
          isLast: isLast,
          isDark: isDark,
          pendingColor: pending,
        );
      }),
    );
  }
}

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({
    required this.step,
    required this.stepColor,
    required this.isCompleted,
    required this.isActive,
    required this.isLast,
    required this.isDark,
    required this.pendingColor,
  });

  final TimelineStepData step;
  final Color stepColor;
  final bool isCompleted;
  final bool isActive;
  final bool isLast;
  final bool isDark;
  final Color pendingColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 50,
          child: Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isActive
                      ? stepColor.withValues(alpha: 0.15)
                      : (isCompleted
                            ? stepColor
                            : stepColor.withValues(alpha: 0.1)),
                  shape: BoxShape.circle,
                  border: isActive
                      ? Border.all(color: stepColor, width: 2.5)
                      : null,
                ),
                child: Icon(
                  isCompleted ? Icons.check_rounded : step.icon,
                  size: 20,
                  color: isCompleted
                      ? Colors.white
                      : (isActive ? stepColor : pendingColor),
                ),
              ),
              if (!isLast)
                Container(
                  width: 2.5,
                  height: 40,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: isCompleted ? stepColor : pendingColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  step.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isActive || isCompleted
                        ? (isDark
                              ? const Color(0xFFE8ECF4)
                              : const Color(0xFF1E2638))
                        : (isDark
                              ? const Color(0xFF6B7280)
                              : const Color(0xFF9CA3AF)),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  step.subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? const Color(0xFF8B95A8)
                        : const Color(0xFF6B7280),
                  ),
                ),
                if (step.dateTime != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    _formatDateTime(step.dateTime!),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: stepColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
