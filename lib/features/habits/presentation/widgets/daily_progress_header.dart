import 'package:material_ui/material_ui.dart';
import '../../../../core/theme/app_color_scheme.dart';

class DailyProgressHeader extends StatelessWidget {
  const DailyProgressHeader({
    super.key,
    required this.completedCount,
    required this.totalCount,
    this.date,
    this.onPreviousDay,
    this.onNextDay,
    this.onDateTap,
  });

  final int completedCount;
  final int totalCount;
  final DateTime? date;
  final VoidCallback? onPreviousDay;
  final VoidCallback? onNextDay;
  final VoidCallback? onDateTap;

  double get progress =>
      totalCount > 0 ? (completedCount / totalCount).clamp(0.0, 1.0) : 0.0;

  bool get isAllCompleted => totalCount > 0 && completedCount == totalCount;

  String _formattedDate(DateTime d) {
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(d.year, d.month, d.day);

    final weekdayName = weekdays[d.weekday - 1];
    final monthName = months[d.month - 1];
    final dateString = '$weekdayName, $monthName ${d.day}';

    if (target == today) {
      return 'Today • $dateString';
    } else if (target == today.subtract(const Duration(days: 1))) {
      return 'Yesterday • $dateString';
    } else if (target == today.add(const Duration(days: 1))) {
      return 'Tomorrow • $dateString';
    }
    return dateString;
  }

  @override
  Widget build(BuildContext context) {
    final effectiveDate = date ?? DateTime.now();
    final percentage = (progress * 100).round();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.outline),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Date Header Row
            Row(
              children: [
                if (onPreviousDay != null) ...[
                  IconButton(
                    icon: const Icon(Icons.chevron_left_rounded),
                    onPressed: onPreviousDay,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    iconSize: 22,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                ],
                Expanded(
                  child: InkWell(
                    onTap: onDateTap,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        _formattedDate(effectiveDate),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ),
                ),
                if (onNextDay != null) ...[
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.chevron_right_rounded),
                    onPressed: onNextDay,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    iconSize: 22,
                    color: AppColors.textSecondary,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 14),

            // Progress bar and percentage in the same row
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: progress),
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return LinearProgressIndicator(
                          value: value,
                          minHeight: 10,
                          backgroundColor: AppColors.surfaceVariant,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.primary,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isAllCompleted
                        ? AppColors.primaryContainer
                        : AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isAllCompleted) ...[
                        const Icon(
                          Icons.check_circle_rounded,
                          size: 14,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        '$percentage%',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isAllCompleted
                              ? AppColors.primary
                              : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Bottom text: Completed count
            Text(
              '$completedCount of $totalCount completed',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
