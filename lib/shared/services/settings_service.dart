import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Keys used for SharedPreferences storage.
abstract final class _Keys {
  static const String soundEnabled = 'settings.soundEnabled';
  static const String vibrationEnabled = 'settings.vibrationEnabled';
  static const String languageCode = 'settings.languageCode';
  static const String timerDuration = 'settings.timerDuration';
}

/// A singleton service that persists and exposes user-adjustable settings.
/// Call [init] once at app start (before runApp) and then read / write
/// settings through the instance.  Listeners are notified via [ChangeNotifier].
class SettingsService extends ChangeNotifier {
  SettingsService._();

  static final SettingsService instance = SettingsService._();

  // ── In-memory state (initialised with defaults) ──────────────────────
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  String _languageCode = 'en-US';
  int _timerDuration = 60; // seconds

  bool get soundEnabled => _soundEnabled;
  bool get vibrationEnabled => _vibrationEnabled;
  String get languageCode => _languageCode;
  int get timerDuration => _timerDuration;

  SharedPreferences? _prefs;

  // ── Initialise: load persisted values ────────────────────────────────
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _soundEnabled = _prefs?.getBool(_Keys.soundEnabled) ?? true;
    _vibrationEnabled = _prefs?.getBool(_Keys.vibrationEnabled) ?? true;
    _languageCode = _prefs?.getString(_Keys.languageCode) ?? 'en-US';
    _timerDuration = _prefs?.getInt(_Keys.timerDuration) ?? 60;
    notifyListeners();
  }

  // ── Setters ──────────────────────────────────────────────────────────

  Future<void> setSoundEnabled(bool value) async {
    if (_soundEnabled == value) return;
    _soundEnabled = value;
    await _prefs?.setBool(_Keys.soundEnabled, value);
    notifyListeners();
  }

  Future<void> setVibrationEnabled(bool value) async {
    if (_vibrationEnabled == value) return;
    _vibrationEnabled = value;
    await _prefs?.setBool(_Keys.vibrationEnabled, value);
    notifyListeners();
  }

  Future<void> setLanguageCode(String code) async {
    if (_languageCode == code) return;
    _languageCode = code;
    await _prefs?.setString(_Keys.languageCode, code);
    notifyListeners();
  }

  Future<void> setTimerDuration(int seconds) async {
    if (_timerDuration == seconds) return;
    _timerDuration = seconds;
    await _prefs?.setInt(_Keys.timerDuration, seconds);
    notifyListeners();
  }
}
