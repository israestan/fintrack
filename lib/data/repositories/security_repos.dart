import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fintrack/data/services/biometric_service.dart';
import 'package:fintrack/domain/models/user_config.dart';

class SecurityRepository {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final BiometricService _biometricService;

  static const String _pinKey = 'fintrack_app_pin';
  static const String _biometricFlagKey = 'fintrack_use_biometric';
  static const String _autoLockEnabledKey = 'fintrack_auto_lock_enabled';
  static const String _autoLockMinutesKey = 'fintrack_auto_lock_minutes';

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
    await setBiometricEnabled(false);
    await setAutoLockEnabled(false);
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
    //Check if hardware is available
    final supported = await _biometricService.isDeviceSupported();
    final canCheck = await _biometricService.canCheckBiometrics();
    return supported && canCheck;
  }

  Future<bool> authenticateWithBiometrics() async {
    return await _biometricService.authenticate();
  }

  Future<void> setAutoLockEnabled(bool enabled) async {
    await _secureStorage.write(
      key: _autoLockEnabledKey,
      value: enabled.toString(),
    );
  }

  Future<void> setAutoLockMinutes(int minutes) async {
    await _secureStorage.write(
      key: _autoLockMinutesKey,
      value: minutes.toString(),
    );
  }

  Future<UserConfig> getUserConfig() async {
    final pinExists = await hasPin();
    final bioEnabled = await isBiometricEnabled();
    final autoLockEnabled =
        (await _secureStorage.read(key: _autoLockEnabledKey)) == 'true';
    final autoLockMinutesStr =
        await _secureStorage.read(key: _autoLockMinutesKey);
    final autoLockMinutes = int.tryParse(autoLockMinutesStr ?? '5') ?? 5;
    return UserConfig(
      hasPin: pinExists,
      useBiometrics: bioEnabled,
      autoLockEnabled: autoLockEnabled,
      autoLockMinutes: autoLockMinutes,
    );
  }
}
