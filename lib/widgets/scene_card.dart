import 'package:flutter/material.dart';
import '../models/scene.dart';
import '../theme/app_theme.dart';

class DurationBadge extends StatelessWidget {
  final double seconds;
  const DurationBadge({super.key, required this.seconds});

  Color _colorFor(DurationStatus status) {
    switch (status) {
      case DurationStatus.green:
        return DurationColors.green;
      case DurationStatus.yellow:
        return DurationColors.yellow;
      case DurationStatus.red:
        return DurationColors.red;
    }
  }

  IconData _iconFor(DurationStatus status) {
    switch (status) {
      case DurationStatus.green:
        return Icons.check_circle;
      case DurationStatus.yellow:
        return Icons.warning_amber_rounded;
      case DurationStatus.red:
        return Icons.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = statusForDuration(seconds);
    final color = _colorFor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_iconFor(status), size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            '${seconds.toStringAsFixed(1)}s',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
