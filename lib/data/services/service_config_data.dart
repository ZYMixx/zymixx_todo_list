import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';

class ServiceConfigData {
  static UserConfig userConfigData = UserConfig();
  static const String _configName = 'zymixx_config.txt';

  static void init() {
    _createConfigFile();
    _readConfigFile();
  }

  static _createConfigFile() {
    File configFile = File(_configName);
    if (!configFile.existsSync()) {
      String jsonString = jsonEncode(UserConfig().toMap())
          .replaceAll(',', ',\n')
          .replaceAll('{', '{\n')
          .replaceAll('}', '\n}');
      configFile.writeAsStringSync(jsonString);
      print('Config file created successfully.');
    } else {
      print('Config file already exists.');
    }
  }

  static _readConfigFile() {
    try {
      File configFile = File(_configName);
      if (configFile.existsSync()) {
        String fileContent = configFile.readAsStringSync();
        String jsonString = fileContent.replaceAll('\n', '');
        Map<String, dynamic> configMap = jsonDecode(jsonString);
        userConfigData = UserConfig.fromMap(configMap);
        print('read all data $configMap.');
      } else {
        print('Config file does not exist.');
        throw FlutterError('Config not exist');
      }
    } catch (e) {
      print(e);
      print('cant Read Config');
    }
  }
}

class UserConfig {
  double winPositionX;
  double winPositionY;

  UserConfig({
    this.winPositionX = 3300,
    this.winPositionY = 80,
  });

  Map<String, dynamic> toMap() {
    return {
    };
  }

  factory UserConfig.fromMap(Map<String, dynamic> map) {
    return UserConfig(
    );
  }
}
