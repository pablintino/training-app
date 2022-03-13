import 'dart:convert';

import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:training_app/app_config.dart';
import 'package:training_app/blocs/auth/auth_models.dart';
import 'package:http/http.dart' as http;

class UserAuthRepository {
  final FlutterAppAuth _appAuth = FlutterAppAuth();
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  final _appConfig = AppConfigLoader().instance;

  String? _accessToken;

  String? get token => _accessToken;

  Future<UserInfo> launchLogin() async {
    final AuthorizationTokenResponse? response =
        await _appAuth.authorizeAndExchangeCode(
      AuthorizationTokenRequest(_appConfig.authClientId,
          'com.pablintino.trainingapp://login-callback',
          issuer: _appConfig.authEndpoint,
          scopes: <String>['offline_access', 'openid', 'profile', 'email'],
          allowInsecureConnections: true,
          promptValues: ['login'],
          preferEphemeralSession: true),
    );
    if (response != null && response.accessToken != null) {
      await _secureStorage.write(
          key: 'refresh_token', value: response.refreshToken);
      _accessToken = response.accessToken!;
      return await getUserDetails();
    }
    throw 'Login process has failed';
  }

  Future<UserInfo> performInitialLogin() async {
    final String? storedRefreshToken =
        await _secureStorage.read(key: 'refresh_token');
    if (storedRefreshToken == null) {
      return launchLogin();
    }

    final TokenResponse? response = await _appAuth.token(TokenRequest(
      _appConfig.authClientId,
      'com.pablintino.trainingapp://login-callback',
      issuer: _appConfig.authEndpoint,
      refreshToken: storedRefreshToken,
    ));
    if (response != null && response.accessToken != null) {
      _accessToken = response.accessToken!;
      return await getUserDetails();
    }
    throw 'Login process has failed';
  }

  Future<void> logout() async {
    await _secureStorage.delete(key: 'refresh_token');
    _accessToken = null;
  }

  Future<UserInfo> getUserDetails() async {
    const String url = 'https://dev-gu3yvto5.eu.auth0.com/oauth2/userinfo';
    final http.Response response = await http.get(
      Uri.parse(url),
      headers: <String, String>{'Authorization': 'Bearer $_accessToken'},
    );

    if (response.statusCode == 200) {
      return UserInfo.fromJson(jsonDecode(response.body));
    } else {
      throw 'Failed to get user details';
    }
  }
}
