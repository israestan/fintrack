import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/app_theme.dart';
import '../view_models/auth_view_model.dart';
import 'main_screen.dart';

enum _AuthStep { biometric, pin }

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  _AuthStep _step = _AuthStep.biometric;
  String _pinInput = '';
  String? _pinError;

  @override
  void initState() {
    super.initState();
    final vm = context.read<AuthViewModel>();
    vm.addListener(_onAuthStateChanged);
    _step = vm.config.useBiometrics ? _AuthStep.biometric : _AuthStep.pin;
    if (_step == _AuthStep.biometric) {
      // Esperar a que la animación de navegación termine antes de lanzar
      // el diálogo biométrico del sistema (evita que Android lo descarte).
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 400), _triggerBiometric);
      });
    }
  }

  @override
  void dispose() {
    context.read<AuthViewModel>().removeListener(_onAuthStateChanged);
    super.dispose();
  }

  void _onAuthStateChanged() {
    if (!mounted) return;
    if (context.read<AuthViewModel>().state == AuthState.authenticated) {
      _goToMain();
    }
  }

  Future<void> _triggerBiometric() async {
    if (!mounted) return;
    await context.read<AuthViewModel>().tryBiometricAuth();
    if (!mounted) return;
    final vm = context.read<AuthViewModel>();
    // Si la bio falló y el PIN está configurado, cambiar al paso de PIN
    if (vm.state != AuthState.authenticated && vm.config.hasPin) {
      setState(() {
        _step = _AuthStep.pin;
        _pinInput = '';
        _pinError = null;
      });
    }
    // Éxito: manejado por _onAuthStateChanged
  }

  void _goToMain() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainScreen()),
    );
  }

  void _onKeyPressed(String key) {
    if (_pinInput.length >= 4) return;
    setState(() {
      _pinInput += key;
      _pinError = null;
    });
    if (_pinInput.length == 4) {
      _verifyPin();
    }
  }

  void _onDelete() {
    if (_pinInput.isEmpty) return;
    setState(() => _pinInput = _pinInput.substring(0, _pinInput.length - 1));
  }

  Future<void> _verifyPin() async {
    await context.read<AuthViewModel>().verifyPin(_pinInput);
    if (!mounted) return;
    final vm = context.read<AuthViewModel>();
    if (vm.state != AuthState.authenticated) {
      setState(() {
        _pinInput = '';
        _pinError = 'PIN incorrecto. Inténtalo de nuevo.';
      });
    }
    // Éxito: manejado por _onAuthStateChanged
  }

  @override
  Widget build(BuildContext context) {
    final authVm = context.watch<AuthViewModel>();
    const primaryColor = AppTheme.primaryColor;
    const backgroundColor = AppTheme.secondaryColor;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _step == _AuthStep.biometric
                  ? _buildBiometricView(authVm, primaryColor)
                  : _buildPinView(authVm, primaryColor),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBiometricView(AuthViewModel authVm, Color primaryColor) {
    final failed = authVm.state == AuthState.unauthenticated &&
        authVm.errorMessage != null;

    return Column(
      key: const ValueKey('bio'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(),

        // Logo
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: primaryColor,
            shape: BoxShape.circle,
          ),
          child: ClipOval(
            child: Image.asset('assets/splash/icon.png', fit: BoxFit.cover),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'FinTrack',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Verifica tu identidad para continuar',
          style: TextStyle(fontSize: AppFontSizes.body, color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),

        const Spacer(),

        // Icono de huella / indicador de carga
        if (authVm.isLoading)
          CircularProgressIndicator(color: primaryColor)
        else
          GestureDetector(
            onTap: _triggerBiometric,
            child: Container(
              padding: const EdgeInsets.all(36),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryColor.withValues(alpha: 0.05),
                border: Border.all(
                  color: failed
                      ? Colors.orange
                      : primaryColor.withValues(alpha: 0.15),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.fingerprint,
                size: 80,
                color: failed ? Colors.orange : primaryColor,
              ),
            ),
          ),

        const SizedBox(height: 20),

        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            authVm.isLoading
                ? 'Verificando...'
                : failed
                    ? 'No se pudo verificar. Toca para reintentar.'
                    : 'Toca el sensor para verificar',
            key: ValueKey(authVm.isLoading ? 0 : failed ? 1 : 2),
            style: TextStyle(
              fontSize: AppFontSizes.body,
              color: failed ? Colors.orange[700] : Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ),

        if (authVm.config.hasPin && !authVm.isLoading) ...[
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => setState(() {
              _step = _AuthStep.pin;
              _pinInput = '';
              _pinError = null;
            }),
            child: Text(
              'Usar PIN',
              style: TextStyle(
                color: primaryColor,
                fontSize: AppFontSizes.body,
              ),
            ),
          ),
        ],

        const Spacer(),
      ],
    );
  }

  Widget _buildPinView(AuthViewModel authVm, Color primaryColor) {
    return Column(
      key: const ValueKey('pin'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(),

        // Logo
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: primaryColor,
            shape: BoxShape.circle,
          ),
          child: ClipOval(
            child: Image.asset('assets/splash/icon.png', fit: BoxFit.cover),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'FinTrack',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Ingresa tu PIN para continuar',
          style: TextStyle(fontSize: AppFontSizes.body, color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 32),

        // Indicadores de dígitos
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(4, (i) {
            final filled = i < _pinInput.length;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: filled ? primaryColor : Colors.transparent,
                border: Border.all(
                  color: _pinError != null ? Colors.red : primaryColor,
                  width: 2,
                ),
              ),
            );
          }),
        ),

        const SizedBox(height: 12),

        if (_pinError != null)
          Text(
            _pinError!,
            style: const TextStyle(
              color: Colors.red,
              fontSize: AppFontSizes.small,
            ),
            textAlign: TextAlign.center,
          ),

        const Spacer(),

        _buildKeypad(primaryColor),

        if (authVm.config.useBiometrics) ...[
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              setState(() {
                _step = _AuthStep.biometric;
                _pinInput = '';
                _pinError = null;
              });
              Future.delayed(
                const Duration(milliseconds: 300),
                _triggerBiometric,
              );
            },
            child: Text(
              'Usar huella dactilar',
              style: TextStyle(
                color: primaryColor,
                fontSize: AppFontSizes.body,
              ),
            ),
          ),
        ],

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildKeypad(Color primaryColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildKeyRow(['1', '2', '3'], primaryColor),
        _buildKeyRow(['4', '5', '6'], primaryColor),
        _buildKeyRow(['7', '8', '9'], primaryColor),
        _buildKeyRow(['', '0', '⌫'], primaryColor),
      ],
    );
  }

  Widget _buildKeyRow(List<String> keys, Color primaryColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: keys.map((k) {
        if (k.isEmpty) {
          return const Expanded(child: SizedBox(height: 64));
        }
        return Expanded(
          child: TextButton(
            onPressed: k == '⌫' ? _onDelete : () => _onKeyPressed(k),
            style: TextButton.styleFrom(
              foregroundColor: primaryColor,
              minimumSize: const Size.fromHeight(64),
              shape: const CircleBorder(),
            ),
            child: k == '⌫'
                ? Icon(Icons.backspace_outlined, color: primaryColor, size: 22)
                : Text(
                    k,
                    style: TextStyle(
                      fontSize: 26,
                      color: primaryColor,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
          ),
        );
      }).toList(),
    );
  }
}

