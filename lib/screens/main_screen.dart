import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/navigation_view_model.dart';
import '../widgets/navbar.dart';
import 'tabs/home_tab.dart';
import 'tabs/movements_tab.dart';
import 'tabs/reports_tab.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  static const List<Widget> _pages = [HomeTab(), MovementsTab(), ReportsTab()];

  @override
  Widget build(BuildContext context) {
    final navViewModel = context.watch<NavigationViewModel>();

    return Scaffold(
      body: IndexedStack(index: navViewModel.currentIndex, children: _pages),
      bottomNavigationBar: const NavBar(),
    );
  }
}
