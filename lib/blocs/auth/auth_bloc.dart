import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:training_app/app_config.dart';
import 'package:training_app/blocs/auth/auth_models.dart';

part 'auth_event.dart';

part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FlutterAppAuth appAuth = FlutterAppAuth();
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
  final appConfig = AppConfigLoader().instance;

  AuthBloc() : super(UnauthenticatedState()) {
    on<InitAppAuthEvent>((event, emit) => _initAction(emit));
    on<LaunchLoginAuthEvent>((event, emit) => _loginAction(emit));
    on<LogoutAuthEvent>((event, emit) => _logoutAction(emit));
  }

  Future<void> _logoutAction(Emitter<AuthState> emit) async {
    await secureStorage.delete(key: 'refresh_token');
    emit(UnauthenticatedState());
  }

  Future<void> _loginAction(Emitter<AuthState> emit) async {
    emit(AuthenticatingState());
    try {
      final AuthorizationTokenResponse? response =
          await appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(appConfig.authClientId,
            'com.pablintino.trainingapp://login-callback',
            issuer: appConfig.authEndpoint,
            scopes: <String>['offline_access', 'openid', 'profile', 'email'],
            allowInsecureConnections: true,
            promptValues: ['login'],
            preferEphemeralSession: true),
      );
      if (response != null && response.accessToken != null) {
        await secureStorage.write(
            key: 'refresh_token', value: response.refreshToken);
        UserInfo userDetails = await _getUserDetails(response.accessToken!);
        emit(AuthenticatedState(userDetails, response.accessToken!));
      }
    } on PlatformException catch (e, _) {
      print(e);
      // todo log or add another state that means failure os something
      emit(UnauthenticatedState());
    }
  }

  Future<void> _initAction(Emitter<AuthState> emit) async {
    emit(AuthenticatingState());
    final String? storedRefreshToken =
        await secureStorage.read(key: 'refresh_token');
    if (storedRefreshToken == null) {
      return this._loginAction(emit);
    }

    final TokenResponse? response = await appAuth.token(TokenRequest(
      appConfig.authClientId,
      'com.pablintino.trainingapp://login-callback',
      issuer: appConfig.authEndpoint,
      refreshToken: storedRefreshToken,
    ));
    if (response != null && response.accessToken != null) {
      UserInfo userDetails = await _getUserDetails(response.accessToken!);
      emit(AuthenticatedState(userDetails, response.accessToken!));
    }
  }

  Future<UserInfo> _getUserDetails(String accessToken) async {
    const String url = 'https://dev-gu3yvto5.eu.auth0.com/oauth2/userinfo';
    final http.Response response = await http.get(
      Uri.parse(url),
      headers: <String, String>{'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 200) {
      return UserInfo.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to get user details');
    }
  }
}
