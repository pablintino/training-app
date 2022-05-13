import 'dart:convert';

import 'package:get_it/get_it.dart';
import 'package:training_app/app_config.dart';
import 'package:training_app/models/auth_models.dart';
import 'package:http/http.dart' as http;
import 'package:training_app/networking/api_security_provider.dart';

class UserAuthRepository {
  late AppConfig _appConfig;
  late ApiSecurityProvider _apiSecurityProvider;
  String? _userProfileUrl;

  UserAuthRepository(
      {ApiSecurityProvider? apiSecurityProvider, AppConfig? appConfig}) {
    this._apiSecurityProvider =
        apiSecurityProvider ?? GetIt.instance<ApiSecurityProvider>();
    this._appConfig = appConfig ?? GetIt.instance<AppConfig>();
  }

  Future<UserInfo> getUserDetails() async {
    final String? userProfileEndpoint = await _getUserProfileUrl();
    if (userProfileEndpoint == null) {
      throw 'User profile endpoint cannot be determined';
    }

    final accessToken = await _apiSecurityProvider.getAccessToken();

    final http.Response response = await http.get(
      Uri.parse(userProfileEndpoint),
      headers: <String, String>{'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 200) {
      return UserInfo.fromJson(jsonDecode(response.body));
    } else {
      throw 'Failed to get user details';
    }
  }

  Future<String?> _getUserProfileUrl() async {
    if (_userProfileUrl != null) {
      return _userProfileUrl;
    }
    final http.Response response = await http.get(Uri.parse(
        '${_appConfig.authEndpoint}/.well-known/openid-configuration'));

    if (response.statusCode == 200) {
      _userProfileUrl = jsonDecode(response.body)['userinfo_endpoint'];
    }
    return _userProfileUrl;
  }
}
