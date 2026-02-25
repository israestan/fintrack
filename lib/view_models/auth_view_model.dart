import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart' show BiometricType;
import 'package:fintrack/data/repositories/security_repos.dart';
import 'package:fintrack/data/services/biometric_service.dart';
import 'package:fintrack/domain/models/user_config.dart';

enum AuthState {
  initial,
  authenticated,
  unauthenticated,
  pinRequired,
  locked,
  error;
}

class AuthViewModel extends ChangeNotifier {
  final SecurityRepository _securityRepo;
  final BiometricService _biometricService;

  AuthState _state = AuthState.initial;
  String? _errorMessage;
  List<BiometricType> _availableBiometrics = [];
  UserConfig _config = const UserConfig(hasPin: false, useBiometrics: false);

  AuthViewModel({
    SecurityRepository? securityRepo,
    BiometricService? biometricService,
  }) : _securityRepo = securityRepo ?? SecurityRepository(),
       _biometricService = biometricService ?? BiometricService();

  AuthState get state => _state;
  String? get errorMessage => _errorMessage;
  List<BiometricType> get availableBiometrics => _availableBiometrics;
  UserConfig get config => _config;

  void _setState(AuthState state) {
    _state = state;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _setState(AuthState.error);
  }

  Future<void> init() async {
    _availableBiometrics = await _biometricService.getAvailableBiometrics();
    await loadConfig();

    if (_config.hasPin) {
      if (_config.useBiometrics) {
        await tryBiometricAuth();
      } else {
        _setState(AuthState.pinRequired);
      }
    } else {
      // No security configured, proceed.
      _setState(AuthState.authenticated);
    }
  }

  Future<void> loadConfig() async {
    _config = await _securityRepo.getUserConfig();
    notifyListeners();
  }

  Future<void> tryBiometricAuth() async {
    final canUse = await _securityRepo.canUseBiometrics();
    if (!canUse) {
      _setState(AuthState.pinRequired);
      return;
    }

    final authenticated = await _securityRepo.authenticateWithBiometrics();
    if (authenticated) {
      _setState(AuthState.authenticated);
      _errorMessage = null;
    } else {
      // Failed bio, fallback to PIN
      _setState(AuthState.pinRequired);
    }
  }

  Future<void> verifyPin(String pin) async {
    try {
      final valid = await _securityRepo.verifyPin(pin);
      if (valid) {
        _setState(AuthState.authenticated);
        _errorMessage = null;
      } else {
        _setError("PIN incorrecto");
      }
    } catch (e) {
      _setError("Error verificando PIN: $e");
    }
  }

  Future<void> setPin(String pin) async {
    try {
      await _securityRepo.savePin(pin);
      await loadConfig();
    } catch (e) {
      _setError("Error guardando PIN: $e");
    }
  }

  Future<void> toggleBiometric(bool enable) async {
    try {
      if (enable) {
        final supported = await _biometricService.isDeviceSupported();
        if (!supported) {
          _setError("Biometría no soportada en este dispositivo");
          return;
        }
      }
      await _securityRepo.setBiometricEnabled(enable);
      await loadConfig();
    } catch (e) {
      _setError("Error configurando biometría: $e");
    }
  }

  Future<void> removePin() async {
    try {
      await _securityRepo.deletePin();
      await loadConfig();
      _setState(AuthState.unauthenticated); // Or reset state logic
    } catch (e) {
      _setError("Error eliminando PIN: $e");
    }
  }
}
