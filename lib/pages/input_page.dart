// lib/pages/input_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/money_type.dart';
import '../models/money_entry.dart';
import '../theme.dart';
import '../constants.dart'; // <-- 定数ファイルをインポートします

class InputPage extends StatefulWidget {
  final MoneyEntry? entry; // nullなら新規、あれば編集

  const InputPage({
    super.key,
    this.entry,
  });

  @override
  State<InputPage> createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {
  MoneyType selectedType = MoneyType.decrease;
  DateTime selectedDate = DateTime.now();

  final amountController = TextEditingController();
  final memoController = TextEditingController();

  bool get isEdit => widget.entry != null;

  @override
  void initState() {
    super.initState();

    if (isEdit) {
      final entry = widget.entry!;
      memoController.text = entry.memo;
      amountController.text = entry.amount.toString();
      selectedType = MoneyType.values.firstWhere(
        (e) => e.name == entry.type,
      );
      selectedDate = entry.date;
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      // 定数を利用
      firstDate: DateTime(AppNumbers.minInputDatePickerYear),
      lastDate: DateTime(AppNumbers.maxDatePickerYear), // period_pageと同じ定数を利用
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void _onTypeChanged(MoneyType type) {
    setState(() {
      selectedType = type;

      if (isEdit) return;
      if (memoController.text.isNotEmpty) return;

      if (type == MoneyType.bankIn) {
        memoController.text = AppStrings.initialMemoBankIn; // 定数を利用
      } else if (type == MoneyType.bankOut) {
        memoController.text = AppStrings.initialMemoBankOut; // 定数を利用
      } else {
        memoController.clear();
      }
    });
  }

  void _delete() {
    widget.entry!.delete();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(AppStrings.deleteSuccessMessage)), // 定数を利用
    );

    Navigator.pop(context);
  }

  void _save() {
    final memo = memoController.text.trim();
    final amountText = amountController.text.trim();

    if (memo.isEmpty || amountText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.inputErrorSnackbarMessage)), // 定数を利用
      );
      return;
    }

    final amount = int.tryParse(amountText);
    if (amount == null) return;

    final box = Hive.box<MoneyEntry>(HiveConstants.moneyBoxName); // 定数を利用

    final newEntry = MoneyEntry(
      amount: amount,
      memo: memo,
      type: selectedType.name,
      date: selectedDate,
    );

    if (isEdit) {
      box.put(widget.entry!.key, newEntry);
    } else {
      box.add(newEntry);
    }

    Navigator.pop(context);
  }

  String get memoLabel {
    switch (selectedType) {
      case MoneyType.decrease:
        return AppStrings.memoLabelDecrease; // 定数を利用
      case MoneyType.increase:
        return AppStrings.memoLabelIncrease; // 定数を利用
      case MoneyType.bankIn:
      case MoneyType.bankOut:
        return AppStrings.memoLabelBank; // 定数を利用
    }
  }

  String get memoHint {
    switch (selectedType) {
      case MoneyType.decrease:
        return AppStrings.memoHintDecrease; // 定数を利用
      case MoneyType.increase:
        return AppStrings.memoHintIncrease; // 定数を利用
      case MoneyType.bankIn:
      case MoneyType.bankOut:
        return AppStrings.memoHintBank; // 定数を利用
    }
  }

  Widget _typeButton(String label, MoneyType type, Color color) {
    final selected = selectedType == type;

    return Expanded(
      child: InkWell(
        onTap: () => _onTypeChanged(type),
        borderRadius: BorderRadius.circular(AppNumbers.typeButtonBorderRadius), // 定数を利用
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppNumbers.mediumSpacing, horizontal: AppNumbers.defaultPadding), // 定数を利用
          decoration: BoxDecoration(
            color: selected
                ? color
                : type == MoneyType.decrease
                    ? AppColors.decreaseBg
                    : type == MoneyType.increase
                        ? AppColors.increaseBg
                        : AppColors.bankBg,
            borderRadius: BorderRadius.circular(AppNumbers.typeButtonBorderRadius), // 定数を利用
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: selected ? Colors.white : Colors.black54,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateText =
        '${selectedDate.year}/${selectedDate.month}/${selectedDate.day}';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: AppNumbers.appBarElevation, // 定数を利用
        title: Text(
          isEdit ? AppStrings.editRecordTitle : AppStrings.newRecordTitle, // 定数を利用
          style: const TextStyle(
            fontSize: AppNumbers.subPageTitleFontSize, // 定数を利用
            fontWeight: FontWeight.bold,
            color: AppColors.pink,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.pink),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppNumbers.defaultPadding + AppNumbers.smallSpacing, vertical: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: _pickDate,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppNumbers.smallSpacing), // 定数を利用
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, size: AppNumbers.calendarIconSize), // 定数を利用
                      const SizedBox(width: AppNumbers.smallSpacing), // 定数を利用
                      Text(dateText),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppNumbers.smallSpacing), // 定数を利用
              const Text(AppStrings.typeSelectionTitle, style: TextStyle(fontWeight: FontWeight.bold, fontSize: AppNumbers.sectionTitleFontSize)), // 定数を利用

              const SizedBox(height: AppNumbers.defaultPadding), // 定数を利用

              Row(
                children: [
                  _typeButton(AppStrings.decreaseTypeLabel, MoneyType.decrease, AppColors.decrease), // 定数を利用
                  const SizedBox(width: AppNumbers.smallSpacing), // 定数を利用
                  _typeButton(AppStrings.increaseTypeLabel, MoneyType.increase, AppColors.increase), // 定数を利用
                ],
              ),
              const SizedBox(height: AppNumbers.smallSpacing), // 定数を利用
              Row(
                children: [
                  _typeButton(AppStrings.bankInTypeLabel, MoneyType.bankIn, AppColors.bank), // 定数を利用
                  const SizedBox(width: AppNumbers.smallSpacing), // 定数を利用
                  _typeButton(AppStrings.bankOutTypeLabel, MoneyType.bankOut, AppColors.bank), // 定数を利用
                ],
              ),

              const SizedBox(height: AppNumbers.defaultPadding + AppNumbers.smallSpacing),

              Text(memoLabel, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: AppNumbers.sectionTitleFontSize)),
              const SizedBox(height: AppNumbers.smallSpacing + 0),
              TextField(
                controller: memoController,
                decoration: InputDecoration(
                  hintText: memoHint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppNumbers.defaultPadding),
                  ),
                ),
              ),

              const SizedBox(height: AppNumbers.defaultPadding),

              const Text(AppStrings.amountLabel, style: TextStyle(fontWeight: FontWeight.bold, fontSize: AppNumbers.sectionTitleFontSize)),
              const SizedBox(height: AppNumbers.smallSpacing + 0),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: const InputDecoration(
                  hintText: AppStrings.amountHint,
                ),
              ),

              const SizedBox(height: AppNumbers.defaultPadding + AppNumbers.smallSpacing),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(AppStrings.cancelButtonText), // 定数を利用
                    ),
                  ),
                  const SizedBox(width: AppNumbers.mediumSpacing), // 定数を利用
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.pink,
                      ),
                      child: Text(isEdit ? AppStrings.updateButtonText : AppStrings.recordButtonText), // 定数を利用
                    ),
                  ),
                ],
              ),

              if (isEdit) ...[
                const SizedBox(height: AppNumbers.mediumSpacing), // 定数を利用
                Center(
                  child: TextButton.icon(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    label: const Text(
                      AppStrings.deleteButtonTextInput, // 定数を利用
                      style: TextStyle(color: Colors.red),
                    ),
                    onPressed: _delete,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

}