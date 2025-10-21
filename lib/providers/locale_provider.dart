import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  static const String _localeKey = "app_locale";

  Locale _locale = const Locale('fr'); // default English
  Locale get locale => _locale;

  LocaleProvider() {
    _loadLocale(); // load saved locale when provider is created
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_localeKey);

    if (languageCode != null) {
      _locale = Locale(languageCode);
      notifyListeners();
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (!['en', 'fr'].contains(locale.languageCode)) return;

    _locale = locale;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
  }

  Future<void> clearLocale() async {
    _locale = const Locale('en');
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_localeKey);
  }
}
