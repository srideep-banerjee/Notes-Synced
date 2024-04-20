import 'package:shared_preferences/shared_preferences.dart';

class PreferencesHelper {
  late Future<SharedPreferences> _sharedPreferencesFuture;

  PreferencesHelper() {
    _sharedPreferencesFuture = SharedPreferences.getInstance();
  }

  Future<bool> containsKey(String key) async {
    return (await _sharedPreferencesFuture).containsKey(key);
  }

  Future<bool?> getBool(String key) async {
    return (await _sharedPreferencesFuture).getBool(key);
  }

  Future<bool> setBool(String key, bool value) async {
    return (await _sharedPreferencesFuture).setBool(key, value);
  }

  Future<String?> getString(String key) async {
    return (await _sharedPreferencesFuture).getString(key);
  }

  Future<bool> setString(String key, String value) async {
    return (await _sharedPreferencesFuture).setString(key, value);
  }
}