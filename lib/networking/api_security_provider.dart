import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:training_app/app_config.dart';

class ApiSecurityProvider {
  static const String APP_PROPERTY_REFRESH_TOKEN = "refresh_token";
  late FlutterAppAuth _appAuth;
  late FlutterSecureStorage _secureStorage;
  final bool _isMainIsolate;
  Function(TokenUpdateData)? _onTokenRefresh;
  late AppConfig _appConfig;
  String? _accessToken;
  String? _refreshToken;

  ApiSecurityProvider(bool isMainIsolate,
      {AppConfig? appConfig,
      FlutterAppAuth? appAuth,
      FlutterSecureStorage? secureStorage})
      : _isMainIsolate = isMainIsolate {
    this._appConfig = appConfig ?? GetIt.instance<AppConfig>();
    this._appAuth = appAuth ?? GetIt.instance<FlutterAppAuth>();
    this._secureStorage =
        secureStorage ?? GetIt.instance<FlutterSecureStorage>();
  }

  Future<String> getAccessToken({bool forceRefresh = false}) async {
    if (!forceRefresh && _accessToken != null) {
      return _accessToken!;
    }

    final refreshToken = await _getUpdateRefreshToken();
    final TokenResponse? response = await _appAuth.token(TokenRequest(
      _appConfig.authClientId,
      _appConfig.authCallback,
      issuer: _appConfig.authEndpoint,
      refreshToken: refreshToken,
    ));

    if (response != null && response.accessToken != null) {
      _accessToken = response.accessToken!;
      _onTokenRefresh?.call(TokenUpdateData(_accessToken, refreshToken));

      return this._accessToken!;
    }
    throw 'Login process has failed';
  }

  Future<String> _getUpdateRefreshToken() async {
    if (_refreshToken != null) {
      return _refreshToken!;
    } else if (_isMainIsolate) {
      // Main isolate gather token from secure storage
      String? storedRefreshToken =
          await _secureStorage.read(key: APP_PROPERTY_REFRESH_TOKEN);
      if (storedRefreshToken != null) {
        _refreshToken = storedRefreshToken;
        return storedRefreshToken;
      }
    } else {
      // Non main isolate with no refresh token set
      throw "Cannot perform login in non main isolate and no refresh-token available";
    }

    // If this is reached a re-login is needed
    final tokenPair = await _login();
    _refreshToken = tokenPair.refreshToken!;
    return _refreshToken!;
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
      _onTokenRefresh?.call(tokenPair);
      return tokenPair;
    }
    throw 'Login process has failed';
  }

  /// Used for setting the access/refresh tokens from outside (example: the isolate
  /// refresh the access token and passes it to the main isolate)
  Future<void> externallySetTokens(
      String? accessToken, String? refreshToken) async {
    this._accessToken = _accessToken;
    this._refreshToken = refreshToken;
    if (_isMainIsolate) {
      await _secureStorage.write(
          key: APP_PROPERTY_REFRESH_TOKEN, value: refreshToken);
    }
  }

  void setOnTokenRefresh(Function(TokenUpdateData) onTokenRefresh) {
    this._onTokenRefresh = onTokenRefresh;
  }

  Future<void> logout() async {
    try {
      await _secureStorage.delete(key: 'refresh_token');
      _onTokenRefresh?.call(TokenUpdateData(null, null));
    } finally {
      _refreshToken = null;
      _accessToken = null;
    }
  }
}

class TokenUpdateData {
  final String? accessToken;
  final String? refreshToken;

  TokenUpdateData(this.accessToken, this.refreshToken);
}
