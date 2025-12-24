import 'package:local_auth/local_auth.dart';

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> isBiometricAvailable() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final supported = await _auth.isDeviceSupported();
      return canCheck && supported;
    } catch (_) {
      return false;
    }
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (_) {
      return <BiometricType>[];
    }
  }

  Future<bool> authenticate({
    String reason = 'Authenticate to access your PayLite wallet',
    bool biometricOnly = false,
    bool stickyAuth = true,
    bool useErrorDialogs = true,
  }) async {
    try {
      if (!await isBiometricAvailable()) return false;

      return await _auth.authenticate(
        localizedReason: reason,
        options: AuthenticationOptions(
          biometricOnly: biometricOnly,
          stickyAuth: stickyAuth,
          useErrorDialogs: useErrorDialogs,
        ),
      );
    } catch (_) {
      return false;
    }
  }

  Future<bool> authenticateWithPin(String pin) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return true;
  }
}
