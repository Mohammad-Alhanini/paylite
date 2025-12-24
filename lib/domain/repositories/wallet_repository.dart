import 'package:payliteapp/data/models/transaction_model.dart';

abstract class WalletRepository {
  Future<double> getBalance();
  Future<void> sendMoney({
    required String recipientEmail,
    required double amount,
  });
  Future<List<TransactionModel>> getLastTransactions({int limit = 5});
}
