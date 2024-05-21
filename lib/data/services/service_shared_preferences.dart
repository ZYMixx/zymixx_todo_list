import 'package:shared_preferences/shared_preferences.dart';

class ServiceSharedPreferences {
  static late SharedPreferences sharedPreferences;

  static init() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }

  static putString({required String key, required String stringData}) {
    sharedPreferences.setString(key, stringData);
  }

  static String? getString({required String key}) {
    return sharedPreferences.getString(key);
  }

  static resetKey({required String key}) {
    sharedPreferences.remove(key);
  }
}
