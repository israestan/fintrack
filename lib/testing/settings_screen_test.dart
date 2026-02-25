import 'package:flutter/material.dart';

class SettingsScreenTest extends StatefulWidget {
  const SettingsScreenTest({super.key});

  @override
  State<SettingsScreenTest> createState() => _SettingsScreenTestState();
}

class _SettingsScreenTestState extends State<SettingsScreenTest> {
  // State variables for toggles and selections
  bool _backupEnabled = true;
  String _selectedCurrency = "USD (\$)";
  bool _biometricEnabled = true;
  String _fontSize = 'Medium';
  String _theme = 'Light';
  final TextEditingController _limitController =
      TextEditingController(text: "2000");

  final Color primaryColor = const Color(0xFF4D1717);

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
          _buildSectionTitle("General"),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text("Moneda Principal",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            subtitle: Text(_selectedCurrency,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
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
          ),
          const SizedBox(height: 24),

          _buildSectionTitle("Límites Financieros"),
          const SizedBox(height: 10),
          const Text(
            "Límite de gasto mensual",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
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
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                const SizedBox(width: 10),
                const Text("\$",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Security Section (Requested)
          Row(
            children: [
              const Text(
                "Seguridad",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              Tooltip(
                message:
                    "Protege el acceso a la aplicación usando tu huella o PIN configurado.",
                triggerMode: TooltipTriggerMode.tap,
                child: Icon(Icons.help_outline,
                    size: 18, color: Colors.grey.shade600),
              ),
            ],
          ),
          _buildSwitchTile(
            title: "Activar seguridad biométrica / PIN",
            subtitle: "Solicitar autenticación al abrir la app.",
            value: _biometricEnabled,
            onChanged: (val) => setState(() => _biometricEnabled = val),
          ),
          const SizedBox(height: 24),

          _buildSectionTitle("Accesibilidad"),
          const SizedBox(height: 10),
          const Text(
            "Tamaño de fuente",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildSelectableButton("Pequeño", _fontSize == 'Small',
                  () => setState(() => _fontSize = 'Small')),
              const SizedBox(width: 10),
              _buildSelectableButton("Mediano", _fontSize == 'Medium',
                  () => setState(() => _fontSize = 'Medium')),
              const SizedBox(width: 10),
              _buildSelectableButton("Grande", _fontSize == 'Large',
                  () => setState(() => _fontSize = 'Large')),
            ],
          ),

          const SizedBox(height: 24),
          _buildSectionTitle("Tema"),
           // Placeholder for theme selection if needed, just mimicking spacing from image
           const SizedBox(height: 10),
           Row(
            children: [
               _buildThemeCircle(Colors.white, true), // Light
               const SizedBox(width: 15),
               _buildThemeCircle(Colors.black, false), // Dark
               const SizedBox(width: 15),
               _buildThemeCircle(const Color(0xFF1B5E20), false), // Green
            ]
           )

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
          fontSize: 18,
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
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // Align top for multiline subtitle
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: primaryColor,
            activeTrackColor: primaryColor.withOpacity(0.3),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.grey.shade300,
          ),
        ],
      ),
    );
  }

  Widget _buildSelectableButton(
      String text, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? primaryColor : Colors.white,
            border: Border.all(
                color: isSelected ? primaryColor : Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
              ),
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
              boxShadow: isSelected ? [
                  BoxShadow(color: primaryColor.withOpacity(0.4), blurRadius: 8, spreadRadius: 2)
              ] : []
          ),
          child: isSelected ? const Icon(Icons.check, color:  Color(0xFF4D1717)) : null,
      );
  }
}
