import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> signIn(String email, String password);
  Future<void> signOut();
  Future<UserEntity?> currentUser();

  Future<bool> authenticateBiometric();
  Future<void> setBiometricEnabled(bool enabled);
  Future<bool> isBiometricEnabled();

  Future<void> markBackground();
  Future<bool> shouldReAuth();
}
