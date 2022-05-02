import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';
import 'package:training_app/models/auth_models.dart';
import 'package:training_app/networking/api_security_provider.dart';
import 'package:training_app/repositories/user_auth_repository.dart';

part 'auth_event.dart';

part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  late UserAuthRepository _userAuthRepository;
  late ApiSecurityProvider _apiSecurityProvider;

  AuthBloc(
      {UserAuthRepository? userAuthRepository,
      ApiSecurityProvider? apiSecurityProvider})
      : super(UnauthenticatedState()) {
    on<LaunchLoginAuthEvent>((event, emit) => _loginAction(emit));
    on<LogoutAuthEvent>((event, emit) => _logoutAction(emit));

    this._apiSecurityProvider =
        apiSecurityProvider ?? GetIt.instance<ApiSecurityProvider>();
    this._userAuthRepository =
        userAuthRepository ?? GetIt.instance<UserAuthRepository>();
  }

  Future<void> _logoutAction(Emitter<AuthState> emit) async {
    await _apiSecurityProvider
        .logout()
        .whenComplete(() => emit(UnauthenticatedState()));
  }

  Future<void> _loginAction(Emitter<AuthState> emit) async {
    emit(AuthenticatingState());
    await _userAuthRepository
        .getUserDetails()
        .then((userDetails) => emit(AuthenticatedState(userDetails)))
        .catchError((error) {
      print(error);
      // todo log or add another state that means failure os something
      emit(UnauthenticatedState());
    });
  }
}
