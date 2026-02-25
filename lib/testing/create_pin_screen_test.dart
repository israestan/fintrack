import 'package:flutter/material.dart';

class CreatePinScreenTest extends StatefulWidget {
  const CreatePinScreenTest({super.key});

  @override
  State<CreatePinScreenTest> createState() => _CreatePinScreenTestState();
}

class _CreatePinScreenTestState extends State<CreatePinScreenTest> {
  final Color backgroundColor = const Color(0xFFFBF2F3);
  final Color primaryColor = const Color(0xFF4D1717);
  final Color surfaceColor = Colors.white;

  // 0: Introducir nuevo PIN
  // 1: Confirmar PIN
  int _step = 0;
  
  String _firstPin = "";
  String _currentPin = "";
  final int pinLength = 4;

  @override
  Widget build(BuildContext context) {
    String title = _step == 0 ? "Crea un PIN de acceso" : "Confirma tu PIN";
    String subtitle = _step == 0 
        ? "Ingresa 4 dígitos para proteger tu información" 
        : "Vuelve a ingresar los 4 dígitos";

    return Scaffold(
      backgroundColor: backgroundColor,
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
            const Spacer(),
            
            // Header: Logo
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
            const SizedBox(height: 30),
            
            // Textos Instrucciones
            Text(
              title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 40),

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
                      color: index < _currentPin.length ? primaryColor : Colors.grey[300],
                    ),
                  );
                }),
              ),
            ),

            const Spacer(),

            // Teclado Numérico
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1.6,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 10,
                ),
                itemCount: 12,
                itemBuilder: (context, index) {
                   if (index == 9) return const SizedBox(); // Vacío izquierda
                   if (index == 10) return _buildKeypadButton("0");
                   if (index == 11) return _buildDeleteButton();
                   return _buildKeypadButton("${index + 1}");
                },
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildKeypadButton(String tempValue) {
    return InkWell(
      onTap: () {
        if (_currentPin.length < pinLength) {
          setState(() {
            _currentPin += tempValue;
          });
          
          if (_currentPin.length == pinLength) {
             _handlePinCompleted();
          }
        }
      },
      borderRadius: BorderRadius.circular(40),
      child: Center(
        child: Text(
          tempValue,
          style: TextStyle(
            fontSize: 28,
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
        if (_currentPin.isNotEmpty) {
          setState(() {
            _currentPin = _currentPin.substring(0, _currentPin.length - 1);
          });
        }
      },
      borderRadius: BorderRadius.circular(40),
      child: Center(
        child: Icon(
          Icons.backspace_outlined,
          color: primaryColor,
          size: 28,
        ),
      ),
    );
  }

  void _handlePinCompleted() {
    // Pequeño delay para que el usuario vea el 4to punto llenarse
    Future.delayed(const Duration(milliseconds: 200), () {
      if (!mounted) return;

      if (_step == 0) {
        // Paso 1 completado: Guardar primer input y pedir confirmación
        setState(() {
          _firstPin = _currentPin;
          _currentPin = "";
          _step = 1;
        });
      } else {
        // Paso 2 completado: Comparar
        if (_currentPin == _firstPin) {
          // ÉXITO
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('PIN creado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
           Navigator.of(context).pop(); // Salir simulation
        } else {
          // ERROR: No coinciden
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Los PINs no coinciden. Inténtalo de nuevo.'),
              backgroundColor: Colors.red,
            ),
          );
          // Reiniciar todo el proceso para mayor seguridad
          setState(() {
            _step = 0;
            _firstPin = "";
            _currentPin = "";
          });
        }
      }
    });
  }
}
