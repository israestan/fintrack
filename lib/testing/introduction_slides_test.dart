import 'package:flutter/material.dart';

class IntroductionSlidesTest extends StatefulWidget {
  const IntroductionSlidesTest({super.key});

  @override
  State<IntroductionSlidesTest> createState() => _IntroductionSlidesTestState();
}

class _IntroductionSlidesTestState extends State<IntroductionSlidesTest> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Datos dummy de los slides
  final List<Map<String, dynamic>> _slides = [
    {
      "image": "assets/splash/icon.png",
      "title": "Bienvenido a\nFinTrack",
      "description":
          "Tu compañero financiero personal para alcanzar tus metas económicas.",
    },
    {
      "icon": Icons.account_balance_wallet_outlined,
      "title": "Registra tus\ningresos y gastos",
      "description":
          "Registra cada transacción sin esfuerzo para saber exactamente a dónde va tu dinero.",
    },
    {
      "icon": Icons.pie_chart_outline,
      "title": "Analiza tus\nhábitos de gasto",
      "description":
          "Visualiza tus datos financieros con gráficos intuitivos y obtén información valiosa.",
    },
    {
      "icon": Icons.lock_outline,
      "title": "Almacenamiento\nSeguro y Privado",
      "description":
          "Tus datos se guardan localmente en tu dispositivo. Más seguro, rápido y completamente privado.",
    },
  ];

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Finalizar/Salir
      Navigator.of(context).pop();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Usamos colores hardcodeados similares a la imagen o al tema del proyecto
    final backgroundColor = const Color(0xFFF5F5F5); // Fondo gris muy claro
    final primaryColor =
        const Color(0xFF4D1717); // Color vino del proyecto (según docs)

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _slides.length,
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return _SlideContent(
                    icon: slide['icon'],
                    image: slide['image'],
                    title: slide['title'],
                    description: slide['description'],
                    primaryColor: primaryColor,
                  );
                },
              ),
            ),
            // Indicadores (Puntos)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _slides.length,
                (index) => _buildDot(index, primaryColor),
              ),
            ),
            const SizedBox(height: 40),
            // Botones de Navegación
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Botón Atrás (Oculto en la primera página)
                  if (_currentPage > 0)
                    TextButton(
                      onPressed: _previousPage,
                      child: Text(
                        "Anterior",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 80), // Espaciador para mantener layout

                  // Botón Siguiente / Finalizar
                  ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      _currentPage == _slides.length - 1
                          ? "Comenzar"
                          : "Siguiente",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(int index, Color color) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 5),
      height: 8,
      width: 8,
      decoration: BoxDecoration(
        color: _currentPage == index ? color : Colors.grey.withOpacity(0.4),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _SlideContent extends StatelessWidget {
  final IconData? icon;
  final String? image;
  final String title;
  final String description;
  final Color primaryColor;

  const _SlideContent({
    this.icon,
    this.image,
    required this.title,
    required this.description,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icono circular o Imagen
          Container(
            height: 120, // Ajustar según necesidad visual
            width: 120,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.15), // Fondo gris circular suave
              shape: BoxShape.circle,
            ),
            padding: image != null ? const EdgeInsets.all(20) : null,
            child: image != null
                ? Image.asset(
                    image!,
                    fit: BoxFit.contain,
                  )
                : Icon(
                    icon,
                    size: 50,
                    color: primaryColor, // Usamos el color primario para el icono
                  ),
          ),
          const SizedBox(height: 40),
          // Título
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28, // Tamaño grande como en la imagen
              fontWeight: FontWeight.w800, // Muy grueso
              color: Colors.black87,
              height: 1.2,
              fontFamily: 'Inter', // Si tuvieras fuente custom, si no default
            ),
          ),
          const SizedBox(height: 20),
          // Descripción
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
