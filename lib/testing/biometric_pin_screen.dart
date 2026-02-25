import 'package:flutter/material.dart';

class BiometricPinScreen extends StatefulWidget {
  const BiometricPinScreen({super.key});

  @override
  State<BiometricPinScreen> createState() => _BiometricPinScreenState();
}

class _BiometricPinScreenState extends State<BiometricPinScreen> {
  final Color backgroundColor = const Color(0xFFFBF2F3);
  final Color primaryColor = const Color(0xFF4D1717);
  final Color surfaceColor = Colors.white;

  String pin = "";
  final int pinLength = 4;
  bool _showPinInput = false; // Estado para alternar entre Biometría y PIN

  @override
  void initState() {
    super.initState();
    // Simular solicitud automática de huella al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _simulateBiometricScan();
    });
  }

  void _simulateBiometricScan() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Simulando escaneo de huella... (Escanea ahora)'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      // AppBar simplificada
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // Header: Logo y Bienvenida
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: primaryColor,
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/splash/icon.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Bienvenido a FinTrack",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _showPinInput ? "Ingresa tu PIN de acceso" : "Valida tu identidad",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),

            // Contenido dinámico (Biometría vs PIN)
            // Usamos Expanded en los hijos para gestionar el espacio vertical
            if (_showPinInput) _buildPinInterface() else _buildBiometricInterface(),
          ],
        ),
      ),
    );
  }

  // Interfaz de Biometría (Defecto)
  Widget _buildBiometricInterface() {
    return Expanded(
      child: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            const Spacer(),
            // Icono de huella grande y animado (simulado)
            GestureDetector(
            onTap: _simulateBiometricScan,
            child: Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryColor.withValues(alpha: 0.05),
                border: Border.all(
                    color: primaryColor.withValues(alpha: 0.1), width: 2),
              ),
              child: Icon(
                Icons.fingerprint,
                size: 80,
                color: primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Toca el sensor para verificar",
            style: TextStyle(color: Colors.grey),
          ),
          const Spacer(),
          // Botón para cambiar a PIN
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: TextButton.icon(
              onPressed: () {
                setState(() {
                  _showPinInput = true;
                });
              },
              icon: Icon(Icons.dialpad, color: primaryColor),
              label: Text(
                "Ingresar PIN",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ),
          ),
        ],
      ),
    ));
  }

  // Interfaz de PIN
  Widget _buildPinInterface() {
    return Expanded(
      flex: 10,
      child: Column(
        children: [
          // Puntos del PIN
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: List.generate(pinLength, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index < pin.length ? primaryColor : Colors.grey[300],
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: 10),

          // Teclado Numérico
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              alignment: Alignment.center,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1.5, // Más ancho para asegurar visibilidad
                  crossAxisSpacing: 25,
                  mainAxisSpacing: 15,
                ),
                itemCount: 12,
                itemBuilder: (context, index) {
                  // Mapeo corregido: 0->1, ... 2->3, ... 8->9
                  if (index == 9) {
                    // Botón inferior izquierdo (Volver a Biometría)
                    return IconButton(
                      onPressed: () {
                        setState(() {
                          _showPinInput = false;
                          pin = "";
                        });
                      },
                      icon: const Icon(Icons.fingerprint),
                      tooltip: "Usar huella",
                      color: primaryColor,
                    );
                  }
                  if (index == 10) return _buildKeypadButton("0");
                  if (index == 11) return _buildDeleteButton();
                  return _buildKeypadButton("${index + 1}");
                },
              ),
            ),
          ),
          
          TextButton(
             onPressed: () {},
             child: Text(
               "¿Olvidaste tu PIN?",
               style: TextStyle(color: Colors.grey[600]),
             ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeypadButton(String tempValue) {
    return InkWell(
      onTap: () {
        if (pin.length < pinLength) {
          setState(() {
            pin += tempValue;
          });
          if (pin.length == pinLength) {
            // Simulador éxito
            Future.delayed(const Duration(milliseconds: 300), () {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('PIN verificado: $pin. Acceso concedido.'),
                    backgroundColor: Colors.green,
                  ),
                );
                setState(() {
                  pin = "";
                });
              }
            });
          }
        }
      },
      borderRadius: BorderRadius.circular(40),
      child: Center(
        child: Text(
          tempValue,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w600,
            color: primaryColor,
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return InkWell(
      onTap: () {
        if (pin.isNotEmpty) {
          setState(() {
            pin = pin.substring(0, pin.length - 1);
          });
        }
      },
      borderRadius: BorderRadius.circular(40),
      child: Center(
        child: Icon(
          Icons.backspace_outlined,
          color: primaryColor,
          size: 24,
        ),
      ),
    );
  }
}
