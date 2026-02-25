import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/navigation_view_model.dart';
import '../screens/settings_screen.dart';

class NavBar extends StatelessWidget {
  const NavBar({super.key});

  @override
  Widget build(BuildContext context) {
    // Escuchamos el ViewModel para saber qué tab está activo
    final navViewModel = context.watch<NavigationViewModel>();

    return BottomNavigationBar(
      currentIndex: navViewModel.currentIndex,
      onTap: (index) {
        if (index == 3) {
          // Caso especial: Settings navega a otra pantalla (push)
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
        } else {
          // Navegación normal
          context.read<NavigationViewModel>().setIndex(index);
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
        BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Movimientos'),
        BottomNavigationBarItem(icon: Icon(Icons.pie_chart), label: 'Reportes'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Configuración'),
      ],
    );
  }
}
