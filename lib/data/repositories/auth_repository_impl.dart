import 'package:paylite/core/services/biometric_service.dart';
import 'package:paylite/core/services/secure_storage_service.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final SecureStorageService _secureStorage;
  final BiometricService _biometricService;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required SecureStorageService secureStorage,
    required BiometricService biometricService,
  }) : _remoteDataSource = remoteDataSource,
       _secureStorage = secureStorage,
       _biometricService = biometricService;

  @override
  Future<UserEntity> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _remoteDataSource.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _secureStorage.saveLastAuthTime();

      return user;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _remoteDataSource.signOut();
      await _secureStorage.clearAll();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      return await _remoteDataSource.getCurrentUser();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> authenticateWithBiometrics() async {
    try {
      return await _biometricService.authenticate();
    } catch (e) {
      throw Exception('Biometric authentication failed: $e');
    }
  }

  @override
  Future<void> saveBiometricPreference(bool enabled) async {
    await _secureStorage.setBiometricEnabled(enabled);
  }

  @override
  Future<bool> isBiometricEnabled() async {
    return await _secureStorage.isBiometricEnabled();
  }

  @override
  Future<bool> shouldReAuthenticate() async {
    return await _secureStorage.shouldReAuthenticate();
  }
}
