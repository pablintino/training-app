part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();
}

class UnauthenticatedState extends AuthState {
  @override
  List<Object> get props => [];
}

class AuthenticatingState extends AuthState {
  @override
  List<Object> get props => [];
}

class AuthenticatedState extends AuthState {
  final UserInfo userInfo;
  final String accessToken;

  AuthenticatedState(this.userInfo, this.accessToken);

  @override
  List<Object> get props => [userInfo, accessToken];
}
