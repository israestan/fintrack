import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/app_theme.dart';
import '../view_models/auth_view_model.dart';

enum _PinStep { create, confirm }

class CreatePinScreen extends StatefulWidget {
  const CreatePinScreen({super.key});

  @override
  State<CreatePinScreen> createState() => _CreatePinScreenState();
}

class _CreatePinScreenState extends State<CreatePinScreen> {
  _PinStep _step = _PinStep.create;
  String _firstPin = '';
  String _input = '';
  String? _error;

  static const int _pinLength = 4;

  void _onKeyPressed(String key) {
    if (_input.length >= _pinLength) return;
    setState(() {
      _input += key;
      _error = null;
    });
    if (_input.length == _pinLength) {
      _handleComplete();
    }
  }

  void _onDelete() {
    if (_input.isEmpty) return;
    setState(() => _input = _input.substring(0, _input.length - 1));
  }

  Future<void> _handleComplete() async {
    if (_step == _PinStep.create) {
      setState(() {
        _firstPin = _input;
        _input = '';
        _step = _PinStep.confirm;
      });
    } else {
      if (_input == _firstPin) {
        await context.read<AuthViewModel>().setPin(_input);
        if (mounted) Navigator.of(context).pop(true);
      } else {
        setState(() {
          _input = '';
          _firstPin = '';
          _step = _PinStep.create;
          _error = 'Los PINs no coinciden. Inténtalo de nuevo.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = AppTheme.primaryColor;
    const backgroundColor = AppTheme.secondaryColor;

    final title = _step == _PinStep.create ? 'Crea tu PIN' : 'Confirma tu PIN';
    final subtitle = _step == _PinStep.create
        ? 'Elige un PIN de 4 dígitos para proteger la app.'
        : 'Ingresa nuevamente tu PIN para confirmar.';

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Configurar PIN'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),

                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: AppFontSizes.body,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 40),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_pinLength, (i) {
                    final filled = i < _input.length;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: filled ? primaryColor : Colors.transparent,
                        border: Border.all(
                          color: _error != null ? Colors.red : primaryColor,
                          width: 2,
                        ),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 12),

                if (_error != null)
                  Text(
                    _error!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: AppFontSizes.small,
                    ),
                    textAlign: TextAlign.center,
                  ),

                const Spacer(),

                _buildKeypad(primaryColor),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
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
