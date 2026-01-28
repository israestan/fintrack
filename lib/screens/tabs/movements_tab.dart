import 'package:flutter/material.dart';
import '../movement_screen.dart';

class MovementsTab extends StatelessWidget {
  const MovementsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const MovementScreen()));
        },
        icon: const Icon(Icons.add),
        label: const Text('Nuevo movimiento'),
      ),
    );
  }
}
