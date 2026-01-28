import 'package:flutter/material.dart';
import '../../widgets/accounts_carousel.dart';
import '../categories_screen.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          const AccountsCarousel(),
          const SizedBox(height: 32),
          Center(
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CategoriesScreen()),
                );
              },
              icon: const Icon(Icons.category),
              label: const Text('Categorías'),
            ),
          ),
        ],
      ),
    );
  }
}


