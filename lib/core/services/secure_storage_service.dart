import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage storage;

  SecureStorageService() : storage = const FlutterSecureStorage();

  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _lastAuthTimeKey = 'last_auth_time';
  static const String _userPinKey = 'user_pin';

  Future<void> savePin(String pin) async {
    await storage.write(key: _userPinKey, value: pin);
  }

  Future<String?> getPin() async {
    return await storage.read(key: _userPinKey);
  }

  Future<bool> verifyPin(String inputPin) async {
    final savedPin = await getPin();
    return savedPin == inputPin;
  }

  Future<void> deletePin() async {
    await storage.delete(key: _userPinKey);
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    await storage.write(key: _biometricEnabledKey, value: enabled.toString());
  }

  Future<bool> isBiometricEnabled() async {
    final value = await storage.read(key: _biometricEnabledKey);
    return value == 'true';
  }

  Future<void> saveLastAuthTime() async {
    final now = DateTime.now().millisecondsSinceEpoch.toString();
    await storage.write(key: _lastAuthTimeKey, value: now);
  }

  Future<DateTime?> getLastAuthTime() async {
    final value = await storage.read(key: _lastAuthTimeKey);
    if (value == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(int.parse(value));
  }

  Future<bool> shouldReAuthenticate() async {
    final lastAuthTime = await getLastAuthTime();
    if (lastAuthTime == null) return true;

    final now = DateTime.now();
    final difference = now.difference(lastAuthTime);
    return difference.inMinutes >= 2;
  }

  Future<void> clearAll() async {
    await storage.deleteAll();
  }
}
