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

class PeriodPage extends StatefulWidget {
  const PeriodPage({super.key});

  @override
  State<PeriodPage> createState() => _PeriodPageState();
}

class _PeriodPageState extends State<PeriodPage> {
  late Box<MoneyEntry> box;

  DateTime fromDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime toDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    box = Hive.box<MoneyEntry>('moneyBox');
  }


  Future<void> _pickDate({
    required DateTime initial,
    required void Function(DateTime) onSelected,
  }) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
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
        elevation: 0,
        title: const Text(
          '期間で見る',
          style: TextStyle(
            color: AppColors.pink,
            fontWeight: FontWeight.bold,
            fontSize: 28,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.pink),
      ),
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box<MoneyEntry> box, _) {
          if (box.isEmpty) {
            return const Center(child: Text('まだ記録がありません'));
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
              case 'increase':
                increase += e.amount;
                break;
              case 'decrease':
                decrease += e.amount;
                break;
              case 'bankIn':
                bank += e.amount;
                break;
              case 'bankOut':
                bank -= e.amount;
                break;
            }
          }

          final periodLabel =
              '${formatDate(fromDate)} 〜 ${formatDate(toDate)}';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 🔹 期間
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.sectionBg,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('■ 日付',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),

                      /// 🔹 期間入力
                      PeriodDateSelector( // 新しいウィジェットを使用
                        date: fromDate,
                        label: 'から',
                        onTap: () => _pickDate(
                          initial: fromDate,
                          onSelected: (d) => fromDate = d,
                        ),
                        formatDate: formatDate, // formatDateを渡す
                      ),
                      const SizedBox(height: 16),
                      PeriodDateSelector( // 新しいウィジェットを使用
                        date: toDate,
                        label: 'まで',
                        onTap: () => _pickDate(
                          initial: toDate,
                          onSelected: (d) => toDate = d,
                        ),
                        formatDate: formatDate, // formatDateを渡す
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                /// 🔹 コピーするボタン
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final text = StringBuffer()
                        ..writeln('${periodLabel} の記録\n')
                        ..writeln('■ 内訳')
                        ..writeln('※銀行については「銀行に預けた」を＋、「銀行から出した」を－として扱っています（手元のお金ではなく銀行残高基準）\n');

                      // タブ区切りのヘッダ
                      text.writeln('日付\t内容\t種別\t金額');

                      for (final e in filtered) {
                        // 日本語のtype名
                        String typeLabel;
                        int signedAmount;

                        switch (e.type) {
                          case 'increase':
                            typeLabel = '増えた';
                            signedAmount = e.amount; // ＋
                            break;
                          case 'decrease':
                            typeLabel = '減った';
                            signedAmount = -e.amount; // －
                            break;
                          case 'bankIn':
                            typeLabel = '銀行入金';
                            signedAmount = e.amount; // ＋
                            break;
                          case 'bankOut':
                            typeLabel = '銀行出金';
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
                        const SnackBar(content: Text('コピーしました！')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.pink,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('この期間の記録をコピー'),
                  ),
                ),

                const SizedBox(height: 20),
                
                /// 🔹 合計
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.sectionBg,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('■ 合計',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      TotalAmountRow( // 新しいウィジェットを使用
                        label: '増えた',
                        value: increase,
                        color: AppColors.increaseAmount,
                        formatAmount: formatAmount,
                      ),
                      const SizedBox(height: 8),
                      TotalAmountRow( // 新しいウィジェットを使用
                        label: '減った',
                        value: decrease,
                        color: AppColors.decreaseAmount,
                        formatAmount: formatAmount,
                      ),
                      const SizedBox(height: 8),
                      TotalAmountRow( // 新しいウィジェットを使用
                        label: '銀行残高',
                        value: bank,
                        color: AppColors.bankAmount,
                        isBank: true,
                        formatAmount: formatAmount,
                      ),

                    ],
                  ),
                ),

                const SizedBox(height: 20),

                /// 🔹 内訳
                const Text('■ 内訳',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...filtered.map((e) => MoneyEntryCard(entry: e)),
              ],
            ),
          );
        },
      ),
    );
  }

}
