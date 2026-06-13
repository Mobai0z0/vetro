import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vetro/core/models/sort_type.dart';

const _kDefaultHomePath = 'homePath';
const _kAccentColor = 'accentColor';
const _kThemeMode = 'themeMode';
const _kSortType = 'sortType';
const _kSortAscending = 'sortAscending';
const _kOpenWithInternal = 'openWithInternal';
const _kLanguageCode = 'languageCode';

class SettingsService {
  SettingsService(this._prefs);
  final SharedPreferences _prefs;

  static Future<SettingsService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return SettingsService(prefs);
  }

  String get homePath => _prefs.getString(_kDefaultHomePath) ?? '';
  set homePath(String value) => _prefs.setString(_kDefaultHomePath, value);

  Color get accentColor {
    final value = _prefs.getInt(_kAccentColor);
    return value != null ? Color(value) : const Color(0xFF6750A4);
  }

  set accentColor(Color color) => _prefs.setInt(_kAccentColor, color.value);

  ThemeMode get themeMode {
    final index = _prefs.getInt(_kThemeMode);
    return ThemeMode.values[index ?? ThemeMode.system.index];
  }

  set themeMode(ThemeMode mode) => _prefs.setInt(_kThemeMode, mode.index);

  bool get openWithInternal => _prefs.getBool(_kOpenWithInternal) ?? true;
  set openWithInternal(bool value) => _prefs.setBool(_kOpenWithInternal, value);

  SortType get sortType {
    final index = _prefs.getInt(_kSortType);
    return SortType.values[index ?? SortType.name.index];
  }

  set sortType(SortType type) => _prefs.setInt(_kSortType, type.index);

  bool get sortAscending => _prefs.getBool(_kSortAscending) ?? true;
  set sortAscending(bool value) => _prefs.setBool(_kSortAscending, value);

  String get languageCode => _prefs.getString(_kLanguageCode) ?? 'system';
  set languageCode(String code) => _prefs.setString(_kLanguageCode, code);
}
