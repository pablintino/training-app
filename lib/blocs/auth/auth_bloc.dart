import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';
import 'package:training_app/blocs/auth/auth_models.dart';
import 'package:training_app/repositories/user_auth_repository.dart';

part 'auth_event.dart';

part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final UserAuthRepository _userAuthRepository;

  AuthBloc()
      : _userAuthRepository = GetIt.instance<UserAuthRepository>(),
        super(UnauthenticatedState()) {
    on<InitAppAuthEvent>((event, emit) => _initAction(emit));
    on<LaunchLoginAuthEvent>((event, emit) => _loginAction(emit));
    on<LogoutAuthEvent>((event, emit) => _logoutAction(emit));
  }

  Future<void> _logoutAction(Emitter<AuthState> emit) async {
    await _userAuthRepository.logout();
    emit(UnauthenticatedState());
  }

  Future<void> _loginAction(Emitter<AuthState> emit) async {
    emit(AuthenticatingState());
    await _userAuthRepository
        .launchLogin()
        .then((userDetails) => emit(AuthenticatedState(userDetails)))
        .catchError((error) {
      print(error);
      // todo log or add another state that means failure os something
      emit(UnauthenticatedState());
    });
  }

  Future<void> _initAction(Emitter<AuthState> emit) async {
    emit(AuthenticatingState());
    await _userAuthRepository
        .performInitialLogin()
        .then((userDetails) => emit(AuthenticatedState(userDetails)))
        .catchError((error) {
      print(error);
      // todo log or add another state that means failure os something
      emit(UnauthenticatedState());
    });
  }
}
