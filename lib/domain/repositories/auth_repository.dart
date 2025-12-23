import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<void> signOut();

  Future<UserEntity?> getCurrentUser();

  Future<bool> authenticateWithBiometrics();

  Future<void> saveBiometricPreference(bool enabled);

  Future<bool> isBiometricEnabled();

  Future<bool> shouldReAuthenticate() async {
    return false;
  }
}
