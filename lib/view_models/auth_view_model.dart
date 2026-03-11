import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart' show BiometricType;
import 'package:fintrack/data/repositories/security_repos.dart';
import 'package:fintrack/data/services/biometric_service.dart';
import 'package:fintrack/domain/models/user_config.dart';

enum AuthState {
  authenticated,
  unauthenticated,
  error;
}

class AuthViewModel extends ChangeNotifier {
  final SecurityRepository _securityRepo;
  final BiometricService _biometricService;

  AuthState _state = AuthState.unauthenticated;
  bool _isLoading = false;
  String? _errorMessage;
  List<BiometricType> _availableBiometrics = [];
  UserConfig _config = const UserConfig(hasPin: false, useBiometrics: false);

  AuthViewModel({
    SecurityRepository? securityRepo,
    BiometricService? biometricService,
  }) : _securityRepo = securityRepo ?? SecurityRepository(),
       _biometricService = biometricService ?? BiometricService();

  AuthState get state => _state;
  bool get isLoading => _isLoading;
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

    if (_config.useBiometrics || _config.hasPin) {
      // Solo marca que se requiere auth. El diálogo lo lanza AuthScreen
      // una vez la navegación ya terminó, evitando bloquear el Splash.
      _setState(AuthState.unauthenticated);
    } else {
      _setState(AuthState.authenticated);
    }
  }

  Future<void> loadConfig() async {
    _config = await _securityRepo.getUserConfig();
    notifyListeners();
  }

  Future<void> tryBiometricAuth() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final authenticated = await _securityRepo.authenticateWithBiometrics();
      _isLoading = false;
      if (authenticated) {
        _errorMessage = null;
        _setState(AuthState.authenticated);
      } else {
        _errorMessage = 'No se pudo verificar la identidad.';
        _setState(AuthState.unauthenticated);
      }
    } catch (_) {
      _isLoading = false;
      _errorMessage = 'No se pudo verificar la identidad.';
      _setState(AuthState.unauthenticated);
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

  Future<bool> toggleBiometric(bool enable) async {
    try {
      await _securityRepo.setBiometricEnabled(enable);
      await loadConfig();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Requiere autenticación biométrica antes de cambiar el estado del toggle.
  /// Retorna true si el cambio fue aplicado satisfactoriamente.
  Future<bool> toggleBiometricWithAuth(bool enable) async {
    final authenticated = await _securityRepo.authenticateWithBiometrics();
    if (!authenticated) return false;
    return await toggleBiometric(enable);
  }

  /// Deshabilita el PIN desde Configuración sin alterar el estado de autenticación.
  /// También deshabilita la biometría (invariante: bio requiere PIN).
  Future<bool> disablePinForSettings() async {
    try {
      await _securityRepo.deletePin();
      await loadConfig();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> removePin() async {
    try {
      await _securityRepo.deletePin();
      await loadConfig();
      _setState(AuthState.unauthenticated);
    } catch (e) {
      _setError("Error eliminando PIN: $e");
    }
  }
}
