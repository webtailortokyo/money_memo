String formatDate(DateTime d) {
    return '${d.year}/${d.month}/${d.day}';
}

String formatAmount(int value) {
    final abs = value.abs();
    return abs.toString().replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+$)'),
    (m) => '${m[1]},',
    );
}