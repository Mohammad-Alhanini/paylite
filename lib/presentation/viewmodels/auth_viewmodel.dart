// presentation/viewmodels/auth_viewmodel.dart
import 'package:flutter/foundation.dart';
import 'package:payliteapp/domain/entities/user_entity.dart';
import 'package:payliteapp/domain/repositories/auth_repository.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _repo;

  AuthViewModel(this._repo);

  UserEntity? _user;
  bool _loading = false;
  String? _error;

  UserEntity? get user => _user;
  bool get isLoading => _loading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;

  Future<void> login(String email, String password) async {
    _setLoading(true);
    _error = null;
    try {
      _user = await _repo.signIn(email.trim(), password.trim());
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    try {
      await _repo.signOut();
      _user = null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadUserIfAny() async {
    _setLoading(true);
    try {
      _user = await _repo.currentUser();
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> biometricAuth() async {
    return await _repo.authenticateBiometric();
  }

  Future<void> markBackground() async {
    await _repo.markBackground();
  }

  Future<bool> shouldReAuth() async {
    return await _repo.shouldReAuth();
  }

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }
}
