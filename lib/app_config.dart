import 'dart:convert';

import 'package:flutter/services.dart';

class AppConfig {
  String apiUrl;
  String authEndpoint;
  String authClientId;
  String authCallback;

  AppConfig(
      this.apiUrl, this.authEndpoint, this.authClientId, this.authCallback);

  factory AppConfig.fromJson(Map<String, dynamic> data) {
    final apiUrl = data['api-endpoint'];
    final authEndpoint = data['auth-endpoint'];
    final authClientId = data['auth-client-id'];
    final authCallback = data['auth-callback'];
    return AppConfig(apiUrl, authEndpoint, authClientId, authCallback);
  }
}

class AppConfigLoader {
  static Future<String> getPath() async {
    return await rootBundle.loadString(
      'assets/config/dev.json',
    );
  }

  static Future<AppConfig> create({String? path}) async {
    // load the json file
    return AppConfig.fromJson(jsonDecode(path ?? await getPath()));
  }
}
