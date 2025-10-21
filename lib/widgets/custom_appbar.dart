import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool centerTitle;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.centerTitle = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          color: Colors.white, // Always white on gradient
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          shadows: [
            Shadow(
              blurRadius: 4,
              color: Colors.black.withOpacity(0.4),
              offset: const Offset(1, 1),
            ),
          ],
        ),
      ),
      centerTitle: centerTitle,
      actions: actions,

      elevation: 0,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          // gradient: LinearGradient(
          //   colors: [
          //     AppColors.gradientStart, // #6972DA
          //     AppColors.gradientEnd, // #7354AF
          //   ],
          //   begin: Alignment.topLeft,
          //   end: Alignment.bottomRight,
          // ),
        ),
      ),
      iconTheme: IconThemeData(
        color: Colors.white, // icons white on gradient
        size: 24,
        shadows: [
          Shadow(
            blurRadius: 3,
            color: Colors.black.withOpacity(0.3),
            offset: const Offset(1, 1),
          ),
        ],
      ),
    );
  }
}
