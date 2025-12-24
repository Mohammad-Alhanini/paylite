import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:payliteapp/data/models/transaction_model.dart';

class WalletRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  Future<void> addTransaction(TransactionModel tx) async {
    final uid = _uid;
    if (uid == null) throw Exception('User not authenticated');

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .add(tx.toMap());
  }

  Future<List<TransactionModel>> getLastTransactions({int limit = 5}) async {
    final uid = _uid;
    if (uid == null) return [];

    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map(TransactionModel.fromDoc).toList();
  }
}
