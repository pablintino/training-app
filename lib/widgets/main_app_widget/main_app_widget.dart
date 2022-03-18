import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:training_app/blocs/auth/auth_bloc.dart';
import 'package:training_app/widgets/home_screen_widget/bloc/home_screen_bloc.dart';
import 'package:training_app/widgets/home_screen_widget/home_screen_widget.dart';
import 'package:training_app/widgets/login_screen_widget/login_screen_widget.dart';

class MainAppWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) => (state is AuthenticatedState)
            ? BlocProvider<HomeScreenBloc>(
                create: (_) => HomeScreenBloc(), child: HomeTabbedWidget())
            : LoginScreenWidget());
  }
}
