import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/money_type.dart';
import '../models/money_entry.dart';
import '../theme.dart';

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
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
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
        memoController.text = '銀行に預けた';
      } else if (type == MoneyType.bankOut) {
        memoController.text = '銀行から出した';
      } else {
        memoController.clear();
      }
    });
  }

  void _delete() {
    widget.entry!.delete();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('削除しました')),
    );

    Navigator.pop(context);
  }

  void _save() {
    final memo = memoController.text.trim();
    final amountText = amountController.text.trim();

    if (memo.isEmpty || amountText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('項目と金額を入力してください')),
      );
      return;
    }

    final amount = int.tryParse(amountText);
    if (amount == null) return;

    final box = Hive.box<MoneyEntry>('moneyBox');

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
        return '何に？';
      case MoneyType.increase:
        return '何で？';
      case MoneyType.bankIn:
      case MoneyType.bankOut:
        return 'メモ';
    }
  }

  String get memoHint {
    switch (selectedType) {
      case MoneyType.decrease:
        return '例：アイス、ゲーム';
      case MoneyType.increase:
        return '例：お小遣い、プレゼント';
      case MoneyType.bankIn:
      case MoneyType.bankOut:
        return '例：〇〇銀行';
    }
  }

  Widget _typeButton(String label, MoneyType type, Color color) {
    final selected = selectedType == type;

    return Expanded(
      child: InkWell(
        onTap: () => _onTypeChanged(type),
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: selected
                ? color
                : type == MoneyType.decrease
                    ? AppColors.decreaseBg
                    : type == MoneyType.increase
                        ? AppColors.increaseBg
                        : AppColors.bankBg, // ここを変更
            borderRadius: BorderRadius.circular(24),
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

    return Scaffold( // Material から Scaffold に変更
      backgroundColor: AppColors.background,
      appBar: AppBar( // このAppBarは前回の修正で追加されているはずです
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          isEdit ? '記録を編集する' : '新しく記録する',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.pink,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.pink),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea( // 必要に応じてSafeAreaを追加すると、ノッチなどからの余白を自動で調整してくれます
        child: SingleChildScrollView( // キーボードが表示された際に内容が隠れないように
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20), // 画面端からの余白
          child: Column(
            // mainAxisSize: MainAxisSize.min, // この行を削除するか、
            // mainAxisSize: MainAxisSize.max, // こちらに変更してください。
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ... 既存のInkWell、Text、Row、TextField、OutlinedButton、ElevatedButtonなどのウィジェット ...

              InkWell(
                onTap: _pickDate,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 18),
                      const SizedBox(width: 8),
                      Text(dateText),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),
              const Text('減った？ 増えた？ 銀行？'),

              const SizedBox(height: 16),

              Row(
                children: [
                  _typeButton('減った', MoneyType.decrease, AppColors.decrease),
                  const SizedBox(width: 8),
                  _typeButton('増えた', MoneyType.increase, AppColors.increase),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _typeButton('銀行に預けた', MoneyType.bankIn, AppColors.bank),
                  const SizedBox(width: 8),
                  _typeButton('銀行から出した', MoneyType.bankOut, AppColors.bank),
                ],
              ),

              const SizedBox(height: 20),

              Text(memoLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              TextField(
                controller: memoController,
                decoration: InputDecoration(
                  hintText: memoHint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              const Text('いくら？', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: const InputDecoration(
                  hintText: '0',
                ),
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('キャンセル'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.pink,
                      ),
                      child: Text(isEdit ? '更新する' : '記録する'),
                    ),
                  ),
                ],
              ),

              if (isEdit) ...[
                const SizedBox(height: 12),
                Center(
                  child: TextButton.icon(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    label: const Text(
                      '削除する',
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
