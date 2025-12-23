abstract class WalletRepository {
  Future<double> getBalance();
  Future<bool> sendMoney({
    required String recipientEmail,
    required double amount,
  });
  Future<List<Map<String, dynamic>>> getTransactions();
}