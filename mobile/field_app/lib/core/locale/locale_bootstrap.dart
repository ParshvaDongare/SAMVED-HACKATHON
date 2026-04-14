import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Loaded in [main] before [runApp] so the first frame uses the saved language.
class LocaleBootstrap {
  LocaleBootstrap._();

  static Locale initial = const Locale('en');

  static Future<void> loadFromPrefs() async {
    final p = await SharedPreferences.getInstance();
    final marathi = p.getBool('citizen_lang_mr') ?? false;
    initial = marathi ? const Locale('mr') : const Locale('en');
  }
}
