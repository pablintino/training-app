import 'dart:convert';

import 'package:flutter/services.dart';

class AppConfig {
  String apiUrl;
  String authEndpoint;
  String authClientId;

  AppConfig(this.apiUrl, this.authEndpoint, this.authClientId);

  factory AppConfig.fromJson(Map<String, dynamic> data) {
    final apiUrl = data['api-endpoint'];
    final authEndpoint = data['auth-endpoint'];
    final authClientId = data['auth-client-id'];
    return AppConfig(apiUrl, authEndpoint, authClientId);
  }
}

class AppConfigLoader {
  static final AppConfigLoader _singleton = AppConfigLoader._internal();

  factory AppConfigLoader() {
    return _singleton;
  }

  AppConfigLoader._internal();

  AppConfig? _config;

  AppConfig get instance {
    if (_config == null) {
      throw 'Config loader not initialized';
    }
    return _config!;
  }

  Future<void> init() async {
    // load the json file
    final configContents = await rootBundle.loadString(
      'assets/config/dev.json',
    );
    _config = AppConfig.fromJson(jsonDecode(configContents));
  }
}
