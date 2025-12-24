class TransactionEntity {
  final String id;
  final String sender;
  final String recipient;
  final double amount;
  final DateTime date;

  TransactionEntity({
    required this.id,
    required this.sender,
    required this.recipient,
    required this.amount,
    required this.date,
  });

  factory TransactionEntity.fromMap(Map<String, dynamic> map) {
    return TransactionEntity(
      id: map['id'] ?? '',
      sender: map['sender'] ?? '',
      recipient: map['recipient'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
    );
  }
}
