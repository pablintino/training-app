import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:training_app/app_config.dart';

class ApiSecurityProvider {
  static const String APP_PROPERTY_REFRESH_TOKEN = "refresh_token";
  late FlutterAppAuth _appAuth;
  late FlutterSecureStorage _secureStorage;
  final bool _canLogin;
  final Function(TokenUpdateData)? _onTokenRefresh;
  late AppConfig _appConfig;
  String? _accessToken;

  ApiSecurityProvider(bool canLogin,
      {AppConfig? appConfig,
      FlutterAppAuth? appAuth,
      FlutterSecureStorage? secureStorage,
      Function(TokenUpdateData)? onTokenRefresh})
      : _canLogin = canLogin,
        _onTokenRefresh = onTokenRefresh {
    this._appConfig = appConfig ?? GetIt.instance<AppConfig>();
    this._appAuth = appAuth ?? GetIt.instance<FlutterAppAuth>();
    this._secureStorage =
        secureStorage ?? GetIt.instance<FlutterSecureStorage>();
  }

  Future<String> getAccessToken({bool forceRefresh = false}) async {
    if (!forceRefresh && _accessToken != null) {
      return _accessToken!;
    }

    final refreshToken = await _getRefreshToken();
    final TokenResponse? response = await _appAuth.token(TokenRequest(
      _appConfig.authClientId,
      _appConfig.authCallback,
      issuer: _appConfig.authEndpoint,
      refreshToken: refreshToken,
    ));

    if (response != null && response.accessToken != null) {
      _accessToken = response.accessToken!;
      if (_onTokenRefresh != null) {
        _onTokenRefresh!(TokenUpdateData(response.accessToken!, refreshToken));
      }
      return this._accessToken!;
    }
    throw 'Login process has failed';
  }

  Future<String> _getRefreshToken() async {
    final String? storedRefreshToken =
        await _secureStorage.read(key: APP_PROPERTY_REFRESH_TOKEN);
    if (storedRefreshToken == null && !_canLogin) {
      throw "Cannot perform login and no refresh-token available";
    } else if (storedRefreshToken == null) {
      final tokenPair = await _login();
      return tokenPair.refreshToken!;
    }
    return storedRefreshToken;
  }

  Future<TokenUpdateData> _login() async {
    final AuthorizationTokenResponse? response =
        await _appAuth.authorizeAndExchangeCode(
      AuthorizationTokenRequest(
          _appConfig.authClientId, _appConfig.authCallback,
          issuer: _appConfig.authEndpoint,
          scopes: <String>['offline_access', 'openid', 'profile', 'email'],
          //TODO Temporarily set to true
          allowInsecureConnections: true,
          promptValues: ['login'],
          preferEphemeralSession: true),
    );
    if (response != null &&
        response.accessToken != null &&
        response.refreshToken != null) {
      await _secureStorage.write(
          key: APP_PROPERTY_REFRESH_TOKEN, value: response.refreshToken);
      _accessToken = response.accessToken;
      final tokenPair =
          TokenUpdateData(response.accessToken!, response.refreshToken!);
      if (_onTokenRefresh != null) {
        _onTokenRefresh!(tokenPair);
      }
      return tokenPair;
    }
    throw 'Login process has failed';
  }

  /// Used for setting the access/refresh tokens from outside (example: the isolate
  /// refresh the access token and passes it to the main isolate)
  Future<void> externallySetTokens(
      String? accessToken, String? refreshToken) async {
    this._accessToken = _accessToken;
    await _secureStorage.write(
        key: APP_PROPERTY_REFRESH_TOKEN, value: refreshToken);
  }

  Future<void> logout() async {
    try {
      await _secureStorage.delete(key: 'refresh_token');
      if (_onTokenRefresh != null) {
        _onTokenRefresh!(TokenUpdateData(null, null));
      }
    } finally {
      _accessToken = null;
    }
  }
}

class TokenUpdateData {
  final String? accessToken;
  final String? refreshToken;

  TokenUpdateData(this.accessToken, this.refreshToken);
}
