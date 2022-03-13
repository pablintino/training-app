part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
}

class InitAppAuthEvent extends AuthEvent {
  @override
  List<Object?> get props => [];
}

class LaunchLoginAuthEvent extends AuthEvent {
  @override
  List<Object?> get props => [];
}

class LogoutAuthEvent extends AuthEvent {
  @override
  List<Object?> get props => [];
}
