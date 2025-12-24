// data/repositories/wallet_repository_impl.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:payliteapp/data/datasources/wallet_remote_datasource.dart';
import 'package:payliteapp/data/models/transaction_model.dart';
import 'package:payliteapp/domain/repositories/wallet_repository.dart';

class WalletRepositoryImpl implements WalletRepository {
  final WalletRemoteDataSource _remote;

  WalletRepositoryImpl(this._remote);

  double _balance = 500000.0;

  @override
  Future<double> getBalance() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _balance;
  }

  @override
  Future<void> sendMoney({
    required String recipientEmail,
    required double amount,
  }) async {
    if (recipientEmail.trim().isEmpty) {
      throw Exception('Recipient email is required');
    }

    if (!recipientEmail.contains('@') || !recipientEmail.contains('.')) {
      throw Exception('Invalid recipient email');
    }

    if (amount <= 0) {
      throw Exception('Amount must be greater than 0');
    }

    if (amount > _balance) {
      throw Exception('Insufficient balance');
    }

    if (amount > 100.0) {
      throw Exception('Transfer limit exceeded');
    }

    await Future.delayed(const Duration(seconds: 1));

    _balance -= amount;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('User not authenticated');

    final tx = TransactionModel(
      id: '',
      userId: uid,
      recipientEmail: recipientEmail,
      amount: amount,
      type: 'sent',
      createdAt: DateTime.now(),
    );

    await _remote.addTransaction(tx);
  }

  @override
  Future<List<TransactionModel>> getLastTransactions({int limit = 5}) async {
    return await _remote.getLastTransactions(limit: limit);
  }
}
