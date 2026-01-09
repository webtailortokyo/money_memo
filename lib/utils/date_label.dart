String dateLabel(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final target = DateTime(date.year, date.month, date.day);

  final diff = today.difference(target).inDays;

  if (diff == 0) return '今日';
  if (diff == 1) return '昨日';

  return '${date.year}/${date.month}/${date.day}';
}
