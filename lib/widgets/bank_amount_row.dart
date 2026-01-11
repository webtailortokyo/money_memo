import 'package:flutter/material.dart';
import '../theme.dart';

class BankAmountRow extends StatelessWidget {
  final Widget amountText;

  const BankAmountRow({
    super.key,
    required this.amountText,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Icon(
          Icons.account_balance,
          size: 16,
          color: AppColors.mainText,
        ),
        const SizedBox(width: 6),
        amountText,
      ],
    );
  }
}
