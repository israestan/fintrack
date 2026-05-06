import 'package:flutter/material.dart';

class IntroductionSlidesTest extends StatefulWidget {
  const IntroductionSlidesTest({super.key});

  @override
  State<IntroductionSlidesTest> createState() => _IntroductionSlidesTestState();
}

class _IntroductionSlidesTestState extends State<IntroductionSlidesTest> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

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
    final backgroundColor = const Color(0xFFF5F5F5); 
    final primaryColor =
        const Color(0xFF4D1717); 
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _slides.length,
                (index) => _buildDot(index, primaryColor),
              ),
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
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
                    const SizedBox(width: 80), 

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
        // ignore: deprecated_member_use
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
          Container(
            height: 120, 
            width: 120,
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: Colors.grey.withOpacity(0.15), 
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
                    color: primaryColor, 
                  ),
          ),
          const SizedBox(height: 40),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800, 
              color: Colors.black87,
              height: 1.2,
              fontFamily: 'Inter', 
            ),
          ),
          const SizedBox(height: 20),
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
