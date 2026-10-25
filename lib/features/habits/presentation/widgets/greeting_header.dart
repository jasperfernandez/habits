import 'package:flutter/material.dart';
import '../../../../core/theme/app_color_scheme.dart';

class GreetingHeader extends StatelessWidget {
  const GreetingHeader({
    super.key,
    this.name = 'Jasper',
    this.time,
    this.style,
    this.iconSize = 22,
  });

  final String? name;
  final DateTime? time;
  final TextStyle? style;
  final double iconSize;

  static String greetingForHour(int hour) {
    if (hour >= 5 && hour < 12) {
      return 'Good morning';
    } else if (hour >= 12 && hour < 17) {
      return 'Good noon';
    } else {
      return 'Good evening';
    }
  }

  static bool isDayTime(int hour) {
    return hour >= 5 && hour < 17;
  }

  @override
  Widget build(BuildContext context) {
    final current = time ?? DateTime.now();
    final greeting = greetingForHour(current.hour);
    final isDay = isDayTime(current.hour);

    final titleText = (name != null && name!.trim().isNotEmpty)
        ? '$greeting, ${name!.trim()}!'
        : '$greeting!';

    final defaultStyle = const TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.5,
      color: AppColors.textPrimary,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          isDay ? Icons.wb_sunny_rounded : Icons.nightlight_round,
          size: iconSize,
          color: isDay ? const Color(0xFFF59E0B) : const Color(0xFF6366F1),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            titleText,
            overflow: TextOverflow.ellipsis,
            style: style ?? defaultStyle,
          ),
        ),
      ],
    );
  }
}
