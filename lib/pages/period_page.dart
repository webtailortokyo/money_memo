// lib/pages/period_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/money_entry.dart';
import '../theme.dart';
import '../widgets/money_entry_card.dart';
import '../widgets/money_amount_text.dart';
import '../widgets/bank_amount_row.dart';
import '../widgets/period_date_selector.dart';
import '../widgets/total_amount_row.dart';
import '../utils/format_utils.dart';
import '../utils/sort_entries.dart';
import '../constants.dart'; // <-- 定数ファイルをインポートします

class PeriodPage extends StatefulWidget {
  const PeriodPage({super.key});

  @override
  State<PeriodPage> createState() => _PeriodPageState();
}

class _PeriodPageState extends State<PeriodPage> {
  late Box<MoneyEntry> box;

  // 定数を利用
  DateTime fromDate = DateTime.now().subtract(const Duration(days: AppNumbers.initialPeriodDays));
  DateTime toDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    box = Hive.box<MoneyEntry>(HiveConstants.moneyBoxName); // 定数を利用
  }


  Future<void> _pickDate({
    required DateTime initial,
    required void Function(DateTime) onSelected,
  }) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      // 定数を利用
      firstDate: DateTime(AppNumbers.minDatePickerYear),
      lastDate: DateTime(AppNumbers.maxDatePickerYear),
    );

    if (picked != null) {
      setState(() => onSelected(picked));
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: AppNumbers.appBarElevation, // 定数を利用
        title: const Text(
          AppStrings.periodPageTitle, // 定数を利用
          style: TextStyle(
            color: AppColors.pink,
            fontWeight: FontWeight.bold,
            fontSize: AppNumbers.titleFontSize, // 定数を利用
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.pink),
      ),
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box<MoneyEntry> box, _) {
          if (box.isEmpty) {
            return const Center(child: Text(AppStrings.noRecordMessage)); // 定数を利用
          }

          final entries = sortedEntries(box);

          final filtered = entries.where((e) {
            final d = DateTime(e.date.year, e.date.month, e.date.day);
            return !d.isBefore(fromDate) && !d.isAfter(toDate);
          }).toList();

          int increase = 0;
          int decrease = 0;
          int bank = 0;

          for (final e in filtered) {
            switch (e.type) {
              case MoneyEntryTypes.increase: // 定数を利用
                increase += e.amount;
                break;
              case MoneyEntryTypes.decrease: // 定数を利用
                decrease += e.amount;
                break;
              case MoneyEntryTypes.bankIn: // 定数を利用
                bank += e.amount;
                break;
              case MoneyEntryTypes.bankOut: // 定数を利用
                bank -= e.amount;
                break;
            }
          }

          final periodLabel =
              '${formatDate(fromDate)} 〜 ${formatDate(toDate)}';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppNumbers.defaultPadding), // 定数を利用
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 🔹 期間
                Container(
                  padding: const EdgeInsets.all(AppNumbers.defaultPadding), // 定数を利用
                  decoration: BoxDecoration(
                    color: AppColors.sectionBg,
                    borderRadius: BorderRadius.circular(AppNumbers.defaultPadding), // 定数を利用
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(AppStrings.dateSectionTitle, // 定数を利用
                              style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: AppNumbers.mediumSpacing), // 定数を利用

                      /// 🔹 期間入力
                      PeriodDateSelector(
                        date: fromDate,
                        label: AppStrings.fromLabel, // 定数を利用
                        onTap: () => _pickDate(
                          initial: fromDate,
                          onSelected: (d) => fromDate = d,
                        ),
                        formatDate: formatDate,
                      ),
                      const SizedBox(height: AppNumbers.defaultPadding), // 定数を利用
                      PeriodDateSelector(
                        date: toDate,
                        label: AppStrings.toLabel, // 定数を利用
                        onTap: () => _pickDate(
                          initial: toDate,
                          onSelected: (d) => toDate = d,
                        ),
                        formatDate: formatDate,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppNumbers.largeSpacing), // 定数を利用
                /// 🔹 コピーするボタン
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final text = StringBuffer()
                        ..writeln('${periodLabel} の記録\n')
                        ..writeln(AppStrings.detailSectionTitle) // 定数を利用
                        ..writeln(AppStrings.clipboardNote); // 定数を利用

                      // タブ区切りのヘッダ
                      text.writeln(AppStrings.clipboardHeader); // 定数を利用

                      for (final e in filtered) {
                        // 日本語のtype名
                        String typeLabel;
                        int signedAmount;

                        switch (e.type) {
                          case MoneyEntryTypes.increase: // 定数を利用
                            typeLabel = AppStrings.increaseTypeLabel; // 定数を利用
                            signedAmount = e.amount; // ＋
                            break;
                          case MoneyEntryTypes.decrease: // 定数を利用
                            typeLabel = AppStrings.decreaseTypeLabel; // 定数を利用
                            signedAmount = -e.amount; // －
                            break;
                          case MoneyEntryTypes.bankIn: // 定数を利用
                            typeLabel = AppStrings.bankInTypeLabel; // 定数を利用
                            signedAmount = e.amount; // ＋
                            break;
                          case MoneyEntryTypes.bankOut: // 定数を利用
                            typeLabel = AppStrings.bankOutTypeLabel; // 定数を利用
                            signedAmount = -e.amount; // －
                            break;
                          default:
                            typeLabel = '';
                            signedAmount = e.amount;
                        }

                        // 金額は ±数字、カンマ無し、¥無し
                        final amountStr = signedAmount.toString();

                        text.writeln(
                          '${formatDate(e.date)}\t'
                          '${e.memo ?? ''}\t'
                          '$typeLabel\t'
                          '$amountStr'
                        );
                      }

                      Clipboard.setData(ClipboardData(text: text.toString()));

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text(AppStrings.copySuccessMessage)), // 定数を利用
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.pink,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: AppNumbers.mediumSpacing), // 定数を利用
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppNumbers.cardBorderRadius), // 定数を利用
                      ),
                    ),
                    child: const Text(AppStrings.copyButtonText), // 定数を利用
                  ),
                ),

                const SizedBox(height: AppNumbers.defaultPadding + AppNumbers.smallSpacing), // 定数を利用 (20を表現)
                
                /// 🔹 合計
                Container(
                  padding: const EdgeInsets.all(AppNumbers.defaultPadding), // 定数を利用
                  decoration: BoxDecoration(
                    color: AppColors.sectionBg,
                    borderRadius: BorderRadius.circular(AppNumbers.cardBorderRadius), // 定数を利用
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(AppStrings.totalSectionTitle, // 定数を利用
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: AppNumbers.defaultPadding), // 定数を利用
                      TotalAmountRow(
                        label: AppStrings.increaseTypeLabel, // 定数を利用
                        value: increase,
                        color: AppColors.increaseAmount,
                        formatAmount: formatAmount,
                      ),
                      const SizedBox(height: AppNumbers.smallSpacing), // 定数を利用
                      TotalAmountRow(
                        label: AppStrings.decreaseTypeLabel, // 定数を利用
                        value: decrease,
                        color: AppColors.decreaseAmount,
                        formatAmount: formatAmount,
                      ),
                      const SizedBox(height: AppNumbers.smallSpacing), // 定数を利用
                      TotalAmountRow(
                        label: AppStrings.bankBalanceLabel, // 定数を利用
                        value: bank,
                        color: AppColors.bankAmount,
                        isBank: true,
                        formatAmount: formatAmount,
                      ),

                    ],
                  ),
                ),

                const SizedBox(height: AppNumbers.defaultPadding + AppNumbers.smallSpacing), // 定数を利用 (20を表現)

                /// 🔹 内訳
                const Text(AppStrings.detailSectionTitle, // 定数を利用
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: AppNumbers.smallSpacing), // 定数を利用
                ...filtered.map((e) => MoneyEntryCard(entry: e)),
              ],
            ),
          );
        },
      ),
    );
  }

}