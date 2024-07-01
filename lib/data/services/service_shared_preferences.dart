import 'package:shared_preferences/shared_preferences.dart';

class ServiceSharedPreferences {
  late SharedPreferences sharedPreferences;

  init() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }

  putString({required String key, required String stringData}) {
    sharedPreferences.setString(key, stringData);
  }

  String? getString({required String key}) {
    return sharedPreferences.getString(key);
  }

  removeKey({required String key}) {
    sharedPreferences.remove(key);
  }
}
