import 'package:flutter/foundation.dart';
import 'package:paylite/domain/entities/user_entity.dart';
import 'package:paylite/domain/usecases/auth_usecase.dart';

class AuthViewModel extends ChangeNotifier {
  final SignInUseCase _signInUseCase;
  final SignOutUseCase _signOutUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final AuthenticateWithBiometricsUseCase authenticateWithBiometricsUseCase;
  final SaveBiometricPreferenceUseCase _saveBiometricPreferenceUseCase;
  final IsBiometricEnabledUseCase _isBiometricEnabledUseCase;

  AuthViewModel({
    required SignInUseCase signInUseCase,
    required SignOutUseCase signOutUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required this.authenticateWithBiometricsUseCase,
    required SaveBiometricPreferenceUseCase saveBiometricPreferenceUseCase,
    required IsBiometricEnabledUseCase isBiometricEnabledUseCase,
    required ShouldReAuthenticateUseCase shouldReAuthenticateUseCase,
  }) : _signInUseCase = signInUseCase,
       _signOutUseCase = signOutUseCase,
       _getCurrentUserUseCase = getCurrentUserUseCase,
       _saveBiometricPreferenceUseCase = saveBiometricPreferenceUseCase,
       _isBiometricEnabledUseCase = isBiometricEnabledUseCase;

  UserEntity? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isAuthenticated = false;
  bool _isBiometricEnabled = false;

  UserEntity? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _isAuthenticated;
  bool get isBiometricEnabled => _isBiometricEnabled;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      final user = await _signInUseCase.execute(
        email: email,
        password: password,
      );

      _currentUser = user;
      _isAuthenticated = true;
      _isBiometricEnabled = await _isBiometricEnabledUseCase.execute();

      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      _setError(e.toString());
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      _setLoading(true);
      await _signOutUseCase.execute();

      _currentUser = null;
      _isAuthenticated = false;
      _isBiometricEnabled = false;

      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      _setError(e.toString());
      rethrow;
    }
  }

  Future<void> checkCurrentUser() async {
    try {
      _setLoading(true);

      final user = await _getCurrentUserUseCase.execute();
      if (user != null) {
        _currentUser = user;
        _isAuthenticated = true;
        _isBiometricEnabled = await _isBiometricEnabledUseCase.execute();
      }

      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      _setError(e.toString());
    }
  }

  Future<void> toggleBiometric(bool enabled) async {
    try {
      await _saveBiometricPreferenceUseCase.execute(enabled);
      _isBiometricEnabled = enabled;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  void clearAuth() {
    _currentUser = null;
    _isAuthenticated = false;
    _errorMessage = null;
    notifyListeners();
  }
}
