import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'theme.dart';

/// Remembers the last theme the site was in, so the next launch opens the
/// intro, dock and system bars in it before the site has even loaded.
/// (The site itself restores the theme from its own localStorage, which
/// the app keeps — only the HTTP cache is cleared on launch.)
class ThemeStore {
  static const _key = 'site_palette_v1';

  static Future<SitePalette> load() async {
    try {
      final raw = (await SharedPreferences.getInstance()).getString(_key);
      if (raw == null) return SitePalette.dark;
      return SitePalette.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return SitePalette.dark;
    }
  }

  static Future<void> save(SitePalette palette) async {
    try {
      await (await SharedPreferences.getInstance())
          .setString(_key, jsonEncode(palette.toJson()));
    } catch (_) {
      // Not being able to remember the theme is harmless.
    }
  }
}
