import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/app_theme.dart';
import '../view_models/auth_view_model.dart';
import '../view_models/text_scale_view_model.dart';
import 'create_pin_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
    bool _backupEnabled = true;
    final String _selectedCurrency = "USD (\$)";
    bool _toggling = false;
    final TextEditingController _limitController =
      TextEditingController(text: "2000");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Configuración",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          /*
          _buildSectionTitle("General"),
           ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text("Moneda Principal",
                style: TextStyle(
                    fontSize: AppFontSizes.body, fontWeight: FontWeight.w500)),
            subtitle: Text(_selectedCurrency,
                style: TextStyle(
                    fontSize: AppFontSizes.small, color: Colors.grey.shade600)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Fake selector
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Selector de moneda (Demo)")));
            },
          ), 
          _buildSwitchTile(
            title: "Copia de seguridad local",
            subtitle: "Guardar respaldo automático diariamente.",
            value: _backupEnabled,
            onChanged: (val) => setState(() => _backupEnabled = val),
          ),*/
          const SizedBox(height: 24),
          _buildSectionTitle("Accesibilidad"),
          const SizedBox(height: 10),
          const Text(
            "Tamaño de fuente",
            style: TextStyle(
                fontSize: AppFontSizes.body, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),
          //Accessibility
          Row(
            children: [
              Expanded(
                child: Consumer<TextScaleViewModel>(builder: (context, vm, _) {
                  return _buildSelectableButton(
                    "Pequeño",
                    vm.scale == 1.0,
                    () {
                      vm.useSmall();
                    },
                    fontSize: AppFontSizes.small,
                  );
                }),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Consumer<TextScaleViewModel>(builder: (context, vm, _) {
                  return _buildSelectableButton(
                    "Mediano",
                    vm.scale == 1.5,
                    () {
                      vm.useMedium();
                    },
                    fontSize: AppFontSizes.body,
                  );
                }),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Consumer<TextScaleViewModel>(builder: (context, vm, _) {
                  return _buildSelectableButton(
                    "Grande",
                    vm.scale == 2.0,
                    () {
                      vm.useLarge();
                    },
                    fontSize: AppFontSizes.title,
                  );
                }),
              ),
            ],
          ),

          const SizedBox(height: 24),
          /* _buildSectionTitle("Límites Financieros"),
          const SizedBox(height: 10),
          const Text(
            "Límite de gasto mensual",
            style: TextStyle(
                fontSize: AppFontSizes.body, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _limitController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                    ),
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: AppFontSizes.body),
                  ),
                ),
                const SizedBox(width: 10),
                const Text("\$",
                    style: TextStyle(
                        fontSize: AppFontSizes.subtitle,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 24), */

          //Security Section
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            children: [
              const Text(
                "Seguridad",
                style: TextStyle(
                    fontSize: AppFontSizes.subtitle,
                    fontWeight: FontWeight.bold),
              ),
              Tooltip(
                message:
                    "Protege el acceso a la aplicación usando tu huella o PIN configurado.",
                triggerMode: TooltipTriggerMode.tap,
                child: Icon(Icons.help_outline,
                    size: 18, color: Colors.grey.shade600),
              ),
            ],
          ),
          Consumer<AuthViewModel>(builder: (context, authVm, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Toggle PIN
                _buildSwitchTile(
                  title: "Activar seguridad por PIN",
                  subtitle: "Solicitar un PIN de 4 dígitos al abrir la app.",
                  value: authVm.config.hasPin,
                  enabled: !_toggling,
                  onChanged: (val) async {
                    if (val) {
                      final created = await Navigator.of(context).push<bool>(
                        MaterialPageRoute(
                          builder: (_) => const CreatePinScreen(),
                        ),
                      );
                      if (created == true && mounted) {
                        await authVm.loadConfig();
                      }
                    } else {
                      setState(() => _toggling = true);
                      try {
                        await authVm.disablePinForSettings();
                      } finally {
                        if (mounted) setState(() => _toggling = false);
                      }
                    }
                  },
                ),
                // Toggle biométrico
                _buildSwitchTile(
                  title: "Activar seguridad biométrica",
                  subtitle: "Solicitar autenticación biométrica al abrir la app.",
                  value: authVm.config.useBiometrics,
                  enabled: !_toggling,
                  onChanged: (val) async {
                    // Invariante: la biometría requiere PIN como respaldo.
                    // Si se activa bio sin PIN configurado, crear PIN primero.
                    if (val && !authVm.config.hasPin) {
                      final created = await Navigator.of(context).push<bool>(
                        MaterialPageRoute(
                          builder: (_) => const CreatePinScreen(),
                        ),
                      );
                      if (created != true || !mounted) return;
                      await authVm.loadConfig();
                    }
                    setState(() => _toggling = true);
                    try {
                      final ok = await authVm.toggleBiometricWithAuth(val);
                      if (!ok && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(authVm.errorMessage ??
                              'Autenticación fallida. No se aplicó el cambio.'),
                        ));
                      }
                    } finally {
                      if (mounted) setState(() => _toggling = false);
                    }
                  },
                ),
                // Auto-lock toggle
                _buildSwitchTile(
                  title: "Bloqueo automático por inactividad",
                  subtitle: (authVm.config.hasPin || authVm.config.useBiometrics)
                      ? "Bloquear la app tras ${authVm.config.autoLockMinutes} min sin actividad."
                      : "Requiere PIN o biometría activa.",
                  value: authVm.config.autoLockEnabled,
                  enabled: !_toggling &&
                      (authVm.config.hasPin || authVm.config.useBiometrics),
                  onChanged: (val) async {
                    setState(() => _toggling = true);
                    try {
                      await authVm.setAutoLockEnabled(val);
                    } finally {
                      if (mounted) setState(() => _toggling = false);
                    }
                  },
                ),
                // Minutes selector (visible only when auto-lock is on)
                if (authVm.config.autoLockEnabled &&
                    (authVm.config.hasPin || authVm.config.useBiometrics))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Tiempo de inactividad",
                            style: TextStyle(
                              fontSize: AppFontSizes.body,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                        DropdownButton<int>(
                          value: authVm.config.autoLockMinutes,
                          underline: const SizedBox.shrink(),
                          items: [1, 2, 5, 10, 15].map((m) {
                            return DropdownMenuItem<int>(
                              value: m,
                              child: Text(
                                '$m min',
                                style: const TextStyle(
                                    fontSize: AppFontSizes.body),
                              ),
                            );
                          }).toList(),
                          onChanged: _toggling
                              ? null
                              : (val) async {
                                  if (val == null) return;
                                  setState(() => _toggling = true);
                                  try {
                                    await authVm.setAutoLockMinutes(val);
                                  } finally {
                                    if (mounted) {
                                      setState(() => _toggling = false);
                                    }
                                  }
                                },
                        ),
                      ],
                    ),
                  ),
              ],
            );
          }),
          if (_toggling)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: LinearProgressIndicator(),
            ),
          const SizedBox(height: 24),
          /* _buildSectionTitle("Tema"),
          const SizedBox(height: 10),
          Row(children: [
            _buildThemeCircle(Colors.white, true), // Light
            const SizedBox(width: 15),
            _buildThemeCircle(Colors.black, false), // Dark
            const SizedBox(width: 15),
            _buildThemeCircle(const Color(0xFF1B5E20), false), // Green
          ]) */
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: AppFontSizes.subtitle,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    bool enabled = true,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: AppFontSizes.body, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                      fontSize: AppFontSizes.small,
                      color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Switch(
            value: value,
            onChanged: enabled ? onChanged : null,
            activeColor: AppTheme.primaryColor,
            activeTrackColor: AppTheme.primaryColor.withOpacity(0.3),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.grey.shade300,
          ),
        ],
      ),
    );
  }

  Widget _buildSelectableButton(
      String text, bool isSelected, VoidCallback onTap,
      {double? fontSize}) {
    // Return a compact, wrap-friendly button so text can flow to multiple lines
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.white,
          border: Border.all(
              color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.visible,
            textScaleFactor: 1.0,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
              fontSize: fontSize ?? AppFontSizes.body,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThemeCircle(Color color, bool isSelected) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade400, width: 1),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.4),
                      blurRadius: 8,
                      spreadRadius: 2)
                ]
              : []),
      child: isSelected
          ? const Icon(Icons.check, color: AppTheme.primaryColor)
          : null,
    );
  }
}
