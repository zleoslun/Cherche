// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

// class AppColors {
//   // Brand gradient colors
//   static const Color gradientStart = Color(0xFF6972DA);
//   static const Color gradientEnd = Color(0xFF7354AF);

//   // Light mode colors
//   static const Color lightBackground = Color(0xFFF8F9F5);
//   static const Color lightTextPrimary = Color(0xFF0A0A64);
//   static const Color lightTextSecondary = Colors.black87;

//   // Dark mode colors
//   static const Color darkBackground = Color(0xFF121212);
//   static const Color darkTextPrimary = Colors.white;
//   static const Color darkTextSecondary = Colors.white70;
// }

// class AppTheme {
//   // 🌞 Light Theme
//   static ThemeData get lightTheme {
//     return ThemeData(
//       brightness: Brightness.light,
//       scaffoldBackgroundColor: AppColors.lightBackground,
//       primaryColor: AppColors.gradientStart,
//       fontFamily: GoogleFonts.poppins().fontFamily,
//       colorScheme: const ColorScheme.light(
//         primary: AppColors.gradientStart,
//         secondary: AppColors.gradientEnd,
//         background: AppColors.lightBackground,
//       ),
//       appBarTheme: const AppBarTheme(
//         backgroundColor:
//             Colors.transparent, // gradient handled in custom appbar
//         foregroundColor: Colors.white,
//         elevation: 0,
//       ),
//       // textTheme: const TextTheme(
//       //   headlineLarge: TextStyle(
//       //     fontSize: 28,
//       //     fontWeight: FontWeight.bold,
//       //     color: AppColors.lightTextPrimary,
//       //   ),
//       //   bodyLarge: TextStyle(fontSize: 16, color: AppColors.lightTextSecondary),
//       //   bodyMedium: TextStyle(fontSize: 14, color: Colors.black54),
//       // ),
//       textTheme: const TextTheme(
//         displayLarge: TextStyle(color: Colors.black),
//         displayMedium: TextStyle(color: Colors.black),
//         displaySmall: TextStyle(color: Colors.black),
//         headlineLarge: TextStyle(color: Colors.black),
//         headlineMedium: TextStyle(color: Colors.black),
//         headlineSmall: TextStyle(color: Colors.black),
//         titleLarge: TextStyle(color: Colors.black),
//         titleMedium: TextStyle(color: Colors.black),
//         titleSmall: TextStyle(color: Colors.black),
//         bodyLarge: TextStyle(color: Colors.black),
//         bodyMedium: TextStyle(color: Colors.black),
//         bodySmall: TextStyle(color: Colors.black),
//         labelLarge: TextStyle(color: Colors.black),
//         labelMedium: TextStyle(color: Colors.black),
//         labelSmall: TextStyle(color: Colors.black),
//       ),
//     );
//   }

//   // 🌙 Dark Theme
//   static ThemeData get darkTheme {
//     return ThemeData(
//       brightness: Brightness.dark,
//       fontFamily: GoogleFonts.poppins().fontFamily,
//       scaffoldBackgroundColor: AppColors.darkBackground,
//       primaryColor: AppColors.gradientStart,
//       colorScheme: const ColorScheme.dark(
//         primary: AppColors.gradientStart,
//         secondary: AppColors.gradientEnd,
//         background: AppColors.darkBackground,
//       ),
//       appBarTheme: const AppBarTheme(
//         backgroundColor: Colors.transparent,
//         foregroundColor: Colors.white,
//         elevation: 0,
//       ),
//       textTheme: const TextTheme(
//         headlineLarge: TextStyle(
//           fontSize: 28,
//           fontWeight: FontWeight.bold,
//           color: AppColors.darkTextPrimary,
//         ),
//         bodyLarge: TextStyle(fontSize: 16, color: AppColors.darkTextSecondary),
//         bodyMedium: TextStyle(fontSize: 14, color: Colors.white60),
//       ),
//     );
//   }
// }

// 2
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Brand primary color - Updated
  static const Color primaryColor = Color(0xFF130E6A);

  // Light mode colors
  static const Color lightBackground = Color(0xFFF8F9F5);
  static const Color lightTextPrimary = Color(0xFF130E6A);
  static const Color lightTextSecondary = Colors.black87;
  static const Color lightCardBackground = Colors.white;
  static const Color lightSurface = Colors.white;

  // Dark mode colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkTextPrimary = Colors.white;
  static const Color darkTextSecondary = Colors.white70;
  static const Color darkCardBackground = Color(0xFF1E1E1E);
  static const Color darkSurface = Color(0xFF1E1E1E);
}

class AppTheme {
  // 🌞 Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBackground,
      primaryColor: AppColors.primaryColor,
      fontFamily: GoogleFonts.poppins().fontFamily,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryColor,
        secondary: AppColors.primaryColor,
        background: AppColors.lightBackground,
        surface: AppColors.lightSurface,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor:
            AppColors.primaryColor, // Solid color instead of transparent
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: Colors.black),
        displayMedium: TextStyle(color: Colors.black),
        displaySmall: TextStyle(color: Colors.black),
        headlineLarge: TextStyle(color: Colors.black),
        headlineMedium: TextStyle(color: Colors.black),
        headlineSmall: TextStyle(color: Colors.black),
        titleLarge: TextStyle(color: Colors.black),
        titleMedium: TextStyle(color: Colors.black),
        titleSmall: TextStyle(color: Colors.black),
        bodyLarge: TextStyle(color: Colors.black),
        bodyMedium: TextStyle(color: Colors.black),
        bodySmall: TextStyle(color: Colors.black),
        labelLarge: TextStyle(color: Colors.black),
        labelMedium: TextStyle(color: Colors.black),
        labelSmall: TextStyle(color: Colors.black),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  // 🌙 Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      fontFamily: GoogleFonts.poppins().fontFamily,
      scaffoldBackgroundColor: AppColors.darkBackground,
      primaryColor: AppColors.primaryColor,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryColor,
        secondary: AppColors.primaryColor,
        background: AppColors.darkBackground,
        surface: AppColors.darkSurface,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primaryColor, // Solid color
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: Colors.white),
        displayMedium: TextStyle(color: Colors.white),
        displaySmall: TextStyle(color: Colors.white),
        headlineLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppColors.darkTextPrimary,
        ),
        headlineMedium: TextStyle(color: Colors.white),
        headlineSmall: TextStyle(color: Colors.white),
        titleLarge: TextStyle(color: Colors.white),
        titleMedium: TextStyle(color: Colors.white),
        titleSmall: TextStyle(color: Colors.white),
        bodyLarge: TextStyle(fontSize: 16, color: AppColors.darkTextSecondary),
        bodyMedium: TextStyle(fontSize: 14, color: Colors.white60),
        bodySmall: TextStyle(color: Colors.white60),
        labelLarge: TextStyle(color: Colors.white),
        labelMedium: TextStyle(color: Colors.white),
        labelSmall: TextStyle(color: Colors.white),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
}
