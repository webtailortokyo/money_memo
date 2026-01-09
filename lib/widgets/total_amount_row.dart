import 'package:flutter/material.dart';
import 'package:money_memo/widgets/bank_amount_row.dart';
import 'package:money_memo/widgets/money_amount_text.dart';

class TotalAmountRow extends StatelessWidget {
    const TotalAmountRow({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    this.isBank = false,
    required this.formatAmount, // formatAmount 関数を引数として受け取る
    });

    final String label;
    final int value;
    final Color color;
    final bool isBank;
    final String Function(int) formatAmount; // 関数の型定義

    @override
    Widget build(BuildContext context) {
    final amountTextWidget = Row(
        children: [
        Text(
            '¥',
            style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            ),
        ),
        const SizedBox(width: 2),
        MoneyAmountText(
            text: formatAmount(value), // 引数で受け取ったformatAmountを使う
            color: color,
            showSign: false,
            numberSize: 24,
        ),
        ],
    );

    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
        Text(label,
            style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        isBank
            ? BankAmountRow(amountText: amountTextWidget)
            : amountTextWidget,
        ],
    );
    }
}