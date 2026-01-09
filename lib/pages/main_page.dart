// lib/pages/main_page.dart

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'period_page.dart';
import 'input_page.dart';
import '../theme.dart';
import '../models/money_entry.dart';
import '../widgets/money_entry_card.dart';
import '../utils/sort_entries.dart';
import '../constants.dart'; // <-- 定数ファイルをインポートします

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
    box = Hive.box<MoneyEntry>(HiveConstants.moneyBoxName); // 定数を利用
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: AppNumbers.appBarElevation, // 定数を利用
        title: const Text(
          AppStrings.appTitle, // 定数を利用
          style: TextStyle(
            color: AppColors.pink,
            fontWeight: FontWeight.bold,
            fontSize: AppNumbers.titleFontSize, // 定数を利用
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
              child: Text(AppStrings.noRecordMessage), // 定数を利用
            );
          }

          final entries = sortedEntries(box);

          return ListView.builder(
            // 定数を利用
            padding: const EdgeInsets.symmetric(
              horizontal: AppNumbers.listViewHorizontalPadding,
              vertical: AppNumbers.listViewVerticalPadding,
            ),
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
                      title: const Text(AppStrings.deleteDialogTitle), // 定数を利用
                      content: const Text(AppStrings.deleteDialogContent), // 定数を利用
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text(AppStrings.cancelButtonText), // 定数を利用
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text(
                            AppStrings.deleteButtonText, // 定数を利用
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