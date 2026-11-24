import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'country.dart';

class PreferencesStore {
  PreferencesStore(this._preferences);

  static const _apiKeyKey = 'api_ninjas_key';
  static const _favoritesKey = 'favorite_countries';
  final SharedPreferences _preferences;

  String get apiKey => _preferences.getString(_apiKeyKey) ?? '';

  Future<void> saveApiKey(String value) async {
    if (value.trim().isEmpty) {
      await _preferences.remove(_apiKeyKey);
    } else {
      await _preferences.setString(_apiKeyKey, value.trim());
    }
  }

  List<Country> get favorites {
    final raw = _preferences.getStringList(_favoritesKey) ?? const [];
    return raw.map((item) {
      try {
        return Country.fromJson(jsonDecode(item) as Map<String, dynamic>);
      } catch (_) {
        return null;
      }
    }).whereType<Country>().toList(growable: false);
  }

  bool isFavorite(String name) =>
      favorites.any((country) => country.name.toLowerCase() == name.toLowerCase());

  Future<void> toggleFavorite(Country country) async {
    final next = favorites.toList();
    final index = next.indexWhere(
      (saved) => saved.name.toLowerCase() == country.name.toLowerCase(),
    );
    if (index >= 0) {
      next.removeAt(index);
    } else {
      next.insert(0, country);
    }
    await _preferences.setStringList(
      _favoritesKey,
      next.map((item) => jsonEncode(item.toJson())).toList(),
    );
  }
}
