import 'package:flutter/material.dart';
import '../theme.dart';
import '../constants.dart';

class PeriodDateSelector extends StatelessWidget {
    const PeriodDateSelector({
    super.key,
    required this.date,
    required this.label,
    required this.onTap,
    required this.formatDate,
    });

    final DateTime date;
    final String label;
    final VoidCallback onTap;
    final String Function(DateTime) formatDate;

    @override
    Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        GestureDetector(
            onTap: onTap,
            child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppNumbers.cardBorderRadius),
            ),
            child: Row(
                children: [
                Text(formatDate(date)),
                const Spacer(),
                const Icon(Icons.calendar_today, size: 18),
                ],
            ),
            ),
        ),
        Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 10.0), // 数値はお好みで調整してください
            child: Text(label, style: const TextStyle(color: AppColors.mainText)),
        ),
        const SizedBox(height: 6),
        ],
    );
    }
}