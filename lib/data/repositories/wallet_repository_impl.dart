import '../../domain/repositories/wallet_repository.dart';

class WalletRepositoryImpl implements WalletRepository {
  @override
  Future<double> getBalance() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return 500000.0;
  }

  @override
  Future<bool> sendMoney({
    required String recipientEmail,
    required double amount,
  }) async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      if (amount <= 0) throw Exception('Amount must be positive');
      if (amount > 100.0) throw Exception('Exceeds daily limit');
      return true;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getTransactions() {
    throw UnimplementedError();
  }
}
