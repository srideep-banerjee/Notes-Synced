import 'package:shared_preferences/shared_preferences.dart';

class PreferencesHelper {
  late Future<SharedPreferences> _sharedPreferencesFuture;

  PreferencesHelper() {
    _sharedPreferencesFuture = SharedPreferences.getInstance();
  }

  Future<bool?> getBool(String key) async {
    return (await _sharedPreferencesFuture).getBool(key);
  }

  void setBool(String key, bool value) async {
    (await _sharedPreferencesFuture).setBool(key, value);
  }

  Future<String?> getString(String key) async {
    return (await _sharedPreferencesFuture).getString(key);
  }

  void setString(String key, String value) async {
    (await _sharedPreferencesFuture).setString(key, value);
  }
}