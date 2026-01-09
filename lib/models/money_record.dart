class MoneyRecord {
  final String amount;
  final String memo;

  MoneyRecord({
    required this.amount,
    required this.memo,
  });

  Map<String, dynamic> toJson() => {
        'amount': amount,
        'memo': memo,
      };

  factory MoneyRecord.fromJson(Map<String, dynamic> json) {
    return MoneyRecord(
      amount: json['amount'],
      memo: json['memo'],
    );
  }
}
