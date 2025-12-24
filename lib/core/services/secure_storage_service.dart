import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _lastAuthTimeKey = 'last_auth_time';
  static const String _backgroundTimeKey = 'background_time';
  static const String _userPinKey = 'user_pin';

  Future<void> savePin(String pin) async {
    await _storage.write(key: _userPinKey, value: pin);
  }

  Future<String?> getPin() async {
    return await _storage.read(key: _userPinKey);
  }

  Future<bool> verifyPin(String inputPin) async {
    final savedPin = await getPin();
    return savedPin != null && savedPin == inputPin;
  }

  Future<void> deletePin() async {
    await _storage.delete(key: _userPinKey);
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    await _storage.write(key: _biometricEnabledKey, value: enabled.toString());
  }

  Future<bool> isBiometricEnabled() async {
    final value = await _storage.read(key: _biometricEnabledKey);
    return value == 'true';
  }

  Future<void> saveLastAuthTime() async {
    final now = DateTime.now().millisecondsSinceEpoch.toString();
    await _storage.write(key: _lastAuthTimeKey, value: now);
  }

  Future<DateTime?> getLastAuthTime() async {
    final value = await _storage.read(key: _lastAuthTimeKey);
    if (value == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(int.parse(value));
  }

  Future<void> saveBackgroundTime() async {
    final now = DateTime.now().millisecondsSinceEpoch.toString();
    await _storage.write(key: _backgroundTimeKey, value: now);
  }

  Future<DateTime?> getBackgroundTime() async {
    final value = await _storage.read(key: _backgroundTimeKey);
    if (value == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(int.parse(value));
  }

  Future<bool> shouldReAuthenticate({int minutes = 2}) async {
    final bgTime = await getBackgroundTime();
    if (bgTime == null) return false;
    return DateTime.now().difference(bgTime).inMinutes >= minutes;
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
