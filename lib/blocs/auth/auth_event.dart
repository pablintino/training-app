part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
}

class LaunchLoginAuthEvent extends AuthEvent {
  @override
  List<Object?> get props => [];
}

class LogoutAuthEvent extends AuthEvent {
  @override
  List<Object?> get props => [];
}
