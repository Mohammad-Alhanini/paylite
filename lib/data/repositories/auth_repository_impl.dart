import 'package:payliteapp/core/services/biometric_service.dart';
import 'package:payliteapp/core/services/secure_storage_service.dart';
import 'package:payliteapp/data/datasources/auth_remote_datasource.dart';
import 'package:payliteapp/domain/entities/user_entity.dart';
import 'package:payliteapp/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;
  final SecureStorageService _storage;
  final BiometricService _biometric;

  AuthRepositoryImpl(this._remote, this._storage, this._biometric);

  @override
  Future<UserEntity> signIn(String email, String password) async {
    final user = await _remote.signIn(email, password);
    await _storage.saveLastAuthTime();
    return user;
  }

  @override
  Future<void> signOut() async {
    await _remote.signOut();
    await _storage.clearAll();
  }

  @override
  Future<UserEntity?> currentUser() async {
    return await _remote.currentUser();
  }

  @override
  Future<bool> authenticateBiometric() async {
    return await _biometric.authenticate();
  }

  @override
  Future<void> setBiometricEnabled(bool enabled) async {
    await _storage.setBiometricEnabled(enabled);
  }

  @override
  Future<bool> isBiometricEnabled() async {
    return await _storage.isBiometricEnabled();
  }

  @override
  Future<void> markBackground() async {
    await _storage.saveBackgroundTime();
  }

  @override
  Future<bool> shouldReAuth() async {
    return await _storage.shouldReAuthenticate(minutes: 2);
  }
}
