import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class SignInUseCase {
  final AuthRepository _authRepository;

  SignInUseCase({required AuthRepository authRepository})
    : _authRepository = authRepository;

  Future<UserEntity> execute({
    required String email,
    required String password,
  }) async {
    return await _authRepository.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
}

class SignOutUseCase {
  final AuthRepository _authRepository;

  SignOutUseCase({required AuthRepository authRepository})
    : _authRepository = authRepository;

  Future<void> execute() async {
    await _authRepository.signOut();
  }
}

class GetCurrentUserUseCase {
  final AuthRepository _authRepository;

  GetCurrentUserUseCase({required AuthRepository authRepository})
    : _authRepository = authRepository;

  Future<UserEntity?> execute() async {
    return await _authRepository.getCurrentUser();
  }
}

class AuthenticateWithBiometricsUseCase {
  final AuthRepository _authRepository;

  AuthenticateWithBiometricsUseCase({required AuthRepository authRepository})
    : _authRepository = authRepository;

  Future<bool> execute() async {
    return await _authRepository.authenticateWithBiometrics();
  }
}

class SaveBiometricPreferenceUseCase {
  final AuthRepository _authRepository;

  SaveBiometricPreferenceUseCase({required AuthRepository authRepository})
    : _authRepository = authRepository;

  Future<void> execute(bool enabled) async {
    await _authRepository.saveBiometricPreference(enabled);
  }
}

class IsBiometricEnabledUseCase {
  final AuthRepository _authRepository;

  IsBiometricEnabledUseCase({required AuthRepository authRepository})
    : _authRepository = authRepository;

  Future<bool> execute() async {
    return await _authRepository.isBiometricEnabled();
  }
}

class ShouldReAuthenticateUseCase {
  final AuthRepository _authRepository;

  ShouldReAuthenticateUseCase({required AuthRepository authRepository})
    : _authRepository = authRepository;

  Future<bool> execute() async {
    return await _authRepository.shouldReAuthenticate();
  }
}

class SaveAuthTimeUseCase {
  final AuthRepository authRepository;

  SaveAuthTimeUseCase({required this.authRepository});

  Future<void> execute() async {
    throw UnimplementedError('سيتم تنفيذه في Repository');
  }
}
