import '../repositories/wallet_repository.dart';

class SendMoneyUseCase {
  final WalletRepository _walletRepository;

  SendMoneyUseCase({required WalletRepository walletRepository})
    : _walletRepository = walletRepository;

  Future<bool> execute({
    required String recipientEmail,
    required double amount,
  }) async {
    return await _walletRepository.sendMoney(
      recipientEmail: recipientEmail,
      amount: amount,
    );
  }
}

class GetBalanceUseCase {
  final WalletRepository _walletRepository;

  GetBalanceUseCase({required WalletRepository walletRepository})
    : _walletRepository = walletRepository;

  Future<double> execute() async {
    return await _walletRepository.getBalance();
  }
}

class GetTransactionsUseCase {
  final WalletRepository _walletRepository;

  GetTransactionsUseCase({required WalletRepository walletRepository})
    : _walletRepository = walletRepository;

  Future<List<Map<String, dynamic>>> execute() async {
    return await _walletRepository.getTransactions();
  }
}

class ToggleBalanceVisibilityUseCase {
  bool _isBalanceVisible = false;

  bool execute() {
    _isBalanceVisible = !_isBalanceVisible;
    return _isBalanceVisible;
  }

  bool get currentState => _isBalanceVisible;
  void reset() => _isBalanceVisible = false;
}
