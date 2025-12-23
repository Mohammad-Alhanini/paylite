import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:paylite/data/models/transaction_model.dart';
import 'package:paylite/domain/usecases/wallet_usecases.dart';

class WalletViewModel extends ChangeNotifier {
  final GetBalanceUseCase _getBalanceUseCase;
  final SendMoneyUseCase _sendMoneyUseCase;
  final ToggleBalanceVisibilityUseCase _toggleBalanceVisibilityUseCase;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  WalletViewModel({
    required GetBalanceUseCase getBalanceUseCase,
    required SendMoneyUseCase sendMoneyUseCase,
    required ToggleBalanceVisibilityUseCase toggleBalanceVisibilityUseCase,
    required GetTransactionsUseCase getTransactionsUseCase,
  }) : _getBalanceUseCase = getBalanceUseCase,
       _sendMoneyUseCase = sendMoneyUseCase,
       _toggleBalanceVisibilityUseCase = toggleBalanceVisibilityUseCase {
    _initializeBalance();
  }

  double _balance = 0.0;
  bool _isLoading = false;
  String? _errorMessage;

  List<TransactionModel> _recentTransactions = [];
  List<TransactionModel> get recentTransactions => _recentTransactions;

  double get balance => _balance;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isBalanceVisible => _toggleBalanceVisibilityUseCase.currentState;

  Future<void> _initializeBalance() async {
    try {
      _balance = await _getBalanceUseCase.execute();
      await loadLastTransactions();
    } catch (e) {
      _balance = 500000.0;
      _recentTransactions = [];
    } finally {
      notifyListeners();
    }
  }

  String get formattedBalance => _balance.toStringAsFixed(3);
  String get maskedBalance => '******';

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void toggleBalanceVisibility() {
    _toggleBalanceVisibilityUseCase.execute();
    notifyListeners();
  }

  void resetBalanceVisibility() {
    _toggleBalanceVisibilityUseCase.reset();
    notifyListeners();
  }

  Future<void> loadLastTransactions() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        _recentTransactions = [];
        notifyListeners();
        return;
      }

      final snap = await _firestore
          .collection('users')
          .doc(uid)
          .collection('transactions')
          .orderBy('createdAt', descending: true)
          .limit(5)
          .get();

      _recentTransactions = snap.docs
          .map((d) => TransactionModel.fromDoc(d))
          .toList();

      notifyListeners();
    } catch (e) {
      print('🔥 loadLastTransactions error: $e');
    }
  }

  Future<bool> sendMoney({
    required String recipientEmail,
    required double amount,
  }) async {
    _setLoading(true);

    try {
      _setError(null);

      if (recipientEmail.isEmpty) {
        throw Exception('Recipient email is required');
      }
      if (amount <= 0) {
        throw Exception('Amount must be greater than 0');
      }
      if (amount > _balance) {
        throw Exception('Insufficient balance');
      }
      if (amount > 100.0) {
        throw Exception('Cannot send more than \$100 per transaction');
      }

      final success = await _sendMoneyUseCase.execute(
        recipientEmail: recipientEmail,
        amount: amount,
      );

      if (!success) {
        throw Exception('Transfer failed');
      }

      _balance -= amount;

      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        final tx = TransactionModel(
          id: '',
          userId: uid,
          recipientEmail: recipientEmail,
          amount: amount,
          type: 'sent',
          createdAt: DateTime.now(),
        );

        print('before add firestore');
        await _firestore
            .collection('users')
            .doc(uid)
            .collection('transactions')
            .add(tx.toMap());
        print('after add firestore');
      }

      await loadLastTransactions();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  String getCurrentBalanceDisplay() {
    return isBalanceVisible ? '$formattedBalance JOD' : maskedBalance;
  }

  Future<void> refreshData() async {
    try {
      _setLoading(true);
      _balance = await _getBalanceUseCase.execute();
      await loadLastTransactions();
    } catch (e) {
      _setError('Failed to refresh data: $e');
    } finally {
      _setLoading(false);
    }
  }
}
