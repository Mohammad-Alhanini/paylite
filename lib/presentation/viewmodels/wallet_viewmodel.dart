// presentation/viewmodels/wallet_viewmodel.dart
import 'package:flutter/foundation.dart';
import 'package:payliteapp/data/models/transaction_model.dart';
import 'package:payliteapp/domain/repositories/wallet_repository.dart';

class WalletViewModel extends ChangeNotifier {
  final WalletRepository _repo;

  WalletViewModel(this._repo);

  double _balance = 0;
  bool _loading = false;
  String? _error;
  bool _showBalance = false;
  List<TransactionModel> _recent = [];

  double get balance => _balance;
  bool get isLoading => _loading;
  String? get error => _error;
  bool get showBalance => _showBalance;
  List<TransactionModel> get recent => _recent;

  String get balanceText =>
      _showBalance ? '${_balance.toStringAsFixed(3)} JOD' : '******';

  Future<void> init() async {
    await refresh();
  }

  Future<void> refresh() async {
    _setLoading(true);
    _error = null;
    try {
      _balance = await _repo.getBalance();
      _recent = await _repo.getLastTransactions(limit: 5);
    } catch (e) {
      _error = e.toString();
      _recent = [];
    } finally {
      _setLoading(false);
    }
  }

  void toggleBalance() {
    _showBalance = !_showBalance;
    notifyListeners();
  }

  Future<bool> sendMoney({
    required String recipientEmail,
    required double amount,
  }) async {
    _setLoading(true);
    _error = null;
    try {
      await _repo.sendMoney(recipientEmail: recipientEmail, amount: amount);
      await refresh();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }
}
