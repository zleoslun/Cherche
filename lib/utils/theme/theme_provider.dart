// import 'package:flutter/material.dart';

// class ThemeProvider with ChangeNotifier {
//   ThemeMode _themeMode = ThemeMode.system;
//   bool autoUploadReminders = false;
//   bool soundEffects = false;

//   ThemeMode get themeMode => _themeMode;

//   bool get isDarkMode {
//     if (_themeMode == ThemeMode.system) {
//       // Get device brightness
//       final brightness =
//           WidgetsBinding.instance.platformDispatcher.platformBrightness;
//       return brightness == Brightness.dark;
//     }
//     return _themeMode == ThemeMode.dark;
//   }

//   void toggleTheme(bool isOn) {
//     _themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
//     notifyListeners();
//   }

//   //
//   void setAutoUploadReminders(bool value) {
//     autoUploadReminders = value;
//     notifyListeners();
//   }

//   void setSoundEffects(bool value) {
//     soundEffects = value;
//     notifyListeners();
//   }


//   void setTheme(ThemeMode mode) {
//     _themeMode = mode;
//     notifyListeners();
//   }
// }



// 2
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  bool autoUploadReminders = false;
  bool soundEffects = false;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      final brightness =
          WidgetsBinding.instance.platformDispatcher.platformBrightness;
      return brightness == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }

  /// Load preferences at startup
  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool("darkMode");
    final autoReminders = prefs.getBool("autoUploadReminders");
    final sound = prefs.getBool("soundEffects");

    if (isDark != null) {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    }
    if (autoReminders != null) autoUploadReminders = autoReminders;
    if (sound != null) soundEffects = sound;

    notifyListeners();
  }

  /// Toggle theme and save
  Future<void> toggleTheme(bool isOn) async {
    _themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("darkMode", isOn);
  }

  Future<void> setAutoUploadReminders(bool value) async {
    autoUploadReminders = value;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("autoUploadReminders", value);
  }

  Future<void> setSoundEffects(bool value) async {
    soundEffects = value;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("soundEffects", value);
  }
}
