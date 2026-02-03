import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart' as local_auth;
import 'package:flutter_riverpod/flutter_riverpod.dart';

final biometricServiceProvider = Provider<BiometricService>((ref) {
  return BiometricService();
});

class BiometricService {
  final local_auth.LocalAuthentication _auth = local_auth.LocalAuthentication();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _keyEmail = 'biometric_email';
  static const String _keyPassword = 'biometric_password';
  static const String _keyEnabled = 'biometric_enabled';

  Future<bool> get isDeviceSupported async {
    try {
      return await _auth.isDeviceSupported();
    } on PlatformException catch (_) {
      return false;
    }
  }

  Future<bool> get hasBiometrics async {
    try {
      return await _auth.canCheckBiometrics;
    } on PlatformException catch (_) {
      return false;
    }
  }

  Future<bool> isBiometricEnabled() async {
    final enabled = await _storage.read(key: _keyEnabled);
    return enabled == 'true';
  }

  Future<List<local_auth.BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } on PlatformException catch (_) {
      return <local_auth.BiometricType>[];
    }
  }

  /// Enables biometrics by storing credentials securely
  Future<bool> enableBiometrics(String email, String password) async {
    final authenticated = await authenticate(
      localizedReason: 'Authenticate to enable biometric login',
    );

    if (authenticated) {
      await _storage.write(key: _keyEmail, value: email);
      await _storage.write(key: _keyPassword, value: password);
      await _storage.write(key: _keyEnabled, value: 'true');
      return true;
    }
    return false;
  }

  /// Disables biometrics and clears stored credentials
  Future<void> disableBiometrics() async {
    await _storage.delete(key: _keyEmail);
    await _storage.delete(key: _keyPassword);
    await _storage.write(key: _keyEnabled, value: 'false');
  }

  /// Authenticates using biometrics and returns stored credentials if successful
  Future<Map<String, String>?> loginWithBiometrics() async {
    final enabled = await isBiometricEnabled();
    if (!enabled) return null;

    final authenticated = await authenticate(
      localizedReason: 'Authenticate to login',
    );

    if (authenticated) {
      final email = await _storage.read(key: _keyEmail);
      final password = await _storage.read(key: _keyPassword);

      if (email != null && password != null) {
        return {'email': email, 'password': password};
      }
    }
    return null;
  }

  Future<bool> authenticate({
    String localizedReason = 'Please authenticate to access this feature',
    bool stickyAuth = true,
  }) async {
    try {
      final isSupported = await isDeviceSupported;
      if (!isSupported) return false;

      // Fallback to basic authentication if options are causing issues
      return await _auth.authenticate(localizedReason: localizedReason);
    } on PlatformException {
      // Basic error handling
      return false;
    }
  }
}
