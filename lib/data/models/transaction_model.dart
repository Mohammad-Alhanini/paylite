import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String id;
  final String userId;
  final String recipientEmail;
  final double amount;
  final String type;
  final DateTime createdAt;

  TransactionModel({
    required this.id,
    required this.userId,
    required this.recipientEmail,
    required this.amount,
    required this.type,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'recipientEmail': recipientEmail,
      'amount': amount,
      'type': type,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory TransactionModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TransactionModel(
      id: doc.id,
      userId: (data['userId'] ?? '') as String,
      recipientEmail: (data['recipientEmail'] ?? '') as String,
      amount: (data['amount'] ?? 0).toDouble(),
      type: (data['type'] ?? 'sent') as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}
