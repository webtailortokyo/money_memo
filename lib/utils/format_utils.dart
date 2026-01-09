String formatDate(DateTime d) {
    return '${d.year}/${d.month}/${d.day}';
}

String formatAmount(int value) { // _ を外し、パブリック関数にする
    final abs = value.abs();
    return abs.toString().replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+$)'),
    (m) => '${m[1]},',
    );
}