import 'package:hive/hive.dart';
import '../models/money_entry.dart';

List<MoneyEntry> sortedEntries(Box<MoneyEntry> box) {
  final list = box.values.toList();

  list.sort((a, b) {
    final dateCompare = b.date.compareTo(a.date);
    if (dateCompare != 0) return dateCompare;

    return b.createdAt.compareTo(a.createdAt);
  });

  return list;
}
