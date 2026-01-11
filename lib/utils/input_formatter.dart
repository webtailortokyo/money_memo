import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

// 数字を入力すると自動でカンマを付けるクラス
class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  static final NumberFormat _formatter = NumberFormat('#,###');

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;

    // カンマを除去して数字だけにする
    final numValue = int.parse(newValue.text.replaceAll(',', ''));
    // カンマを付け直す
    final newString = _formatter.format(numValue);

    return TextEditingValue(
      text: newString,
      selection: TextSelection.collapsed(offset: newString.length),
    );
  }
}