import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fintrack/data/services/biometric_service.dart';
import 'package:fintrack/domain/models/user_config.dart';

class SecurityRepository {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final BiometricService _biometricService;

  static const String _pinKey = 'fintrack_app_pin';
  static const String _biometricFlagKey = 'fintrack_use_biometric';

  SecurityRepository({BiometricService? biometricService})
      : _biometricService = biometricService ?? BiometricService();

  Future<void> savePin(String pin) async {
    await _secureStorage.write(key: _pinKey, value: pin);
  }

  Future<bool> verifyPin(String attempt) async {
    final storedPin = await _secureStorage.read(key: _pinKey);
    return storedPin == attempt;
  }

  Future<bool> deletePin() async {
    await _secureStorage.delete(key: _pinKey);
    // Also disable biometrics if PIN is removed (as fallback is required)
    await setBiometricEnabled(false);
    return true;
  }

  Future<bool> hasPin() async {
    final pin = await _secureStorage.read(key: _pinKey);
    return pin != null && pin.isNotEmpty;
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    await _secureStorage.write(
      key: _biometricFlagKey,
      value: enabled.toString(),
    );
  }

  Future<bool> isBiometricEnabled() async {
    final val = await _secureStorage.read(key: _biometricFlagKey);
    return val == 'true';
  }

  Future<bool> canUseBiometrics() async {
    final enabled = await isBiometricEnabled();
    if (!enabled) return false;
    // Check if hardware available
    final supported = await _biometricService.isDeviceSupported();
    final canCheck = await _biometricService.canCheckBiometrics();
    return supported && canCheck;
  }

  Future<bool> authenticateWithBiometrics() async {
    return await _biometricService.authenticate();
  }

  Future<UserConfig> getUserConfig() async {
    final pinExists = await hasPin();
    final bioEnabled = await isBiometricEnabled();
    return UserConfig(
      hasPin: pinExists,
      useBiometrics: bioEnabled,
    );
  }
}
