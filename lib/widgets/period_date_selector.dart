import 'package:flutter/material.dart';

class PeriodDateSelector extends StatelessWidget {
    const PeriodDateSelector({
    super.key,
    required this.date,
    required this.label,
    required this.onTap,
    required this.formatDate, // formatDate 関数を引数として受け取る
    });

    final DateTime date;
    final String label;
    final VoidCallback onTap;
    final String Function(DateTime) formatDate; // 関数の型定義

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
                borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
                children: [
                Text(formatDate(date)), // 引数で受け取ったformatDateを使う
                const Spacer(),
                const Icon(Icons.calendar_today, size: 18),
                ],
            ),
            ),
        ),
        Text(label, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 6),
        ],
    );
    }
}