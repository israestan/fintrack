import 'package:flutter/material.dart';
import '../domain/enums.dart';

class IconPicker extends StatelessWidget {
  const IconPicker({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Selecciona un ícono',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: AccountIcon.values.length,
            itemBuilder: (context, index) {
              final icon = AccountIcon.values[index];
              return InkWell(
                onTap: () => Navigator.pop(context, icon),
                customBorder: const CircleBorder(),
                child: CircleAvatar(
                  backgroundColor: Colors.grey[200],
                  child: Icon(icon.toIconData, color: Colors.black87),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
