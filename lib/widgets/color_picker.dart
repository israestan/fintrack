import 'package:flutter/material.dart';
import '../domain/enums.dart';

class ColorPicker extends StatelessWidget {
  const ColorPicker({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Selecciona un color',
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
            itemCount: AccountColor.values.length,
            itemBuilder: (context, index) {
              final color = AccountColor.values[index];
              return InkWell(
                onTap: () => Navigator.pop(context, color),
                customBorder: const CircleBorder(),
                child: CircleAvatar(backgroundColor: color.toColor),
              );
            },
          ),
        ],
      ),
    );
  }
}
