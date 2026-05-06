// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'biometric_pin_screen.dart';
import 'create_pin_screen_test.dart';
import 'introduction_slides_test.dart';
import 'settings_screen_test.dart';
import 'accessibility_scaling_test_screen.dart';

class TestMenuScreen extends StatelessWidget {
  const TestMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menú de Pruebas (Fake UI)'),
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildMenuItem(
            context,
            title: 'Introduction Slides',
            subtitle: 'Pantalla de introducción on-boarding',
            icon: Icons.slideshow,
            targetScreen: const IntroductionSlidesTest(),
          ),
          _buildMenuItem(
            context,
            title: 'Biometric & PIN Lock',
            subtitle: 'Pantalla de bloqueo y seguridad',
            icon: Icons.fingerprint,
            targetScreen: const BiometricPinScreen(),
          ),
          _buildMenuItem(
            context,
            title: 'Create PIN',
            subtitle: 'Flujo de creación de PIN',
            icon: Icons.lock_reset,
            targetScreen: const CreatePinScreenTest(),
          ),
          _buildMenuItem(
            context,
            title: 'Settings Screen',
            subtitle: 'Pantalla de configuración ficticia',
            icon: Icons.settings,
            targetScreen: const SettingsScreenTest(),
          ),
          _buildMenuItem(
            context,
            title: 'Accesibilidad (Escalado 200%)',
            subtitle: 'Prueba de texto dinámico y layout flexible',
            icon: Icons.text_increase,
            targetScreen: const AccessibilityScalingTestScreen(),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget targetScreen,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.deepOrangeAccent.withOpacity(0.1),
          child: Icon(icon, color: Colors.deepOrangeAccent),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => targetScreen),
          );
        },
      ),
    );
  }
}
