import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'period_page.dart';
import 'input_page.dart';
import '../theme.dart';
import '../models/money_entry.dart';
import '../widgets/money_entry_card.dart';
import '../utils/sort_entries.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late Box<MoneyEntry> box;

  @override
  void initState() {
    super.initState();
    box = Hive.box<MoneyEntry>('moneyBox');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'おかねメモ',
          style: TextStyle(
            color: AppColors.pink,
            fontWeight: FontWeight.bold,
            fontSize: 28,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            color: AppColors.pink,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PeriodPage(),
                ),
              );
            },
          ),
        ],
      ),

      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box<MoneyEntry> box, _) {
          if (box.isEmpty) {
            return const Center(
              child: Text('まだ記録がありません'),
            );
          }

          final entries = sortedEntries(box);

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];

              return MoneyEntryCard(
                entry: entry,

                /// 編集
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => InputPage(entry: entry),
                    ),
                  );
                },

                /// 削除
                onLongPress: () async {
                  final result = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('削除しますか？'),
                      content: const Text('この記録を削除します。'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('キャンセル'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text(
                            '削除',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );

                  if (result == true) {
                    box.delete(entry.key);
                  }
                },
              );
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.pink,
        shape: const CircleBorder(),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const InputPage(),
            ),
          );
        },
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}
