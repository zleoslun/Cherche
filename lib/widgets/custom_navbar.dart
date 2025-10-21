import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final icons = [Icons.home, Icons.chat, Icons.settings];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        // gradient: const LinearGradient(
        //   colors: [Color(0xFF6972DA), Color(0xFF7354AF)],
        //   begin: Alignment.topLeft,
        //   end: Alignment.bottomRight,
        // ),
        color: Color(0xFF130E6A),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(icons.length, (index) {
          final isSelected = index == currentIndex;

          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              onTap(index);
            },
            child: Icon(
              icons[index],
              size: isSelected ? 30 : 26,
              color: isSelected ? Colors.white : Colors.white70,
            ),
          );
        }),
      ),
    );
  }
}
