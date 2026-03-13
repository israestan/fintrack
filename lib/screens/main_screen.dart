import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/navigation_view_model.dart';
import '../view_models/auth_view_model.dart';
import '../widgets/navbar.dart';
import 'tabs/home_tab.dart';
import 'tabs/movements_tab.dart';
import 'tabs/reports_tab.dart';
import 'auth_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  static const List<Widget> _pages = [HomeTab(), MovementsTab(), ReportsTab()];

  @override
  void initState() {
    super.initState();
    context.read<AuthViewModel>().addListener(_onAuthChanged);
  }

  @override
  void dispose() {
    context.read<AuthViewModel>().removeListener(_onAuthChanged);
    super.dispose();
  }

  void _onAuthChanged() {
    if (!mounted) return;
    final vm = context.read<AuthViewModel>();
    if (vm.state == AuthState.unauthenticated &&
        (vm.config.hasPin || vm.config.useBiometrics)) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AuthScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final navViewModel = context.watch<NavigationViewModel>();

    return Scaffold(
      body: IndexedStack(index: navViewModel.currentIndex, children: _pages),
      bottomNavigationBar: const NavBar(),
    );
  }
}
