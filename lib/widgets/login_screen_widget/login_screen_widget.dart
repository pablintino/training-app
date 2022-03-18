import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:training_app/blocs/auth/auth_bloc.dart';

class LoginScreenWidget extends StatelessWidget {
  static const routeName = '/welcome-screen';

  Container _buildLoginButton(BuildContext ctx, bool isLoading) {
    return Container(
      height: 80,
      width: double.infinity,
      padding: const EdgeInsets.only(top: 25, left: 24, right: 24),
      child: ElevatedButton(
        onPressed: !isLoading
            ? () => BlocProvider.of<AuthBloc>(ctx).add(LaunchLoginAuthEvent())
            : null,
        style: ButtonStyle(
          foregroundColor:
              MaterialStateProperty.resolveWith<Color>((_) => Colors.white),
          backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
            if (states.contains(MaterialState.disabled)) {
              return Colors.grey.withOpacity(0.4); // Disabled color
            }
            return Colors.blue; // Regular color
          }),
        ),
        child: Text(
          !isLoading ? 'Login' : 'Loading...',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Container _buildLoadingSpinner(BuildContext ctx) {
    return Container(
        height: 150,
        padding: const EdgeInsets.only(top: 25, left: 24, right: 24),
        child: Column(
          children: [
            Center(
              child: CircularProgressIndicator(),
            ),
            Container(
              child: Text('Logging in...',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                  )),
              padding: EdgeInsets.all(25),
            )
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          decoration: new BoxDecoration(
            image: new DecorationImage(
              image: new AssetImage("assets/images/login-background.jpg"),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 6,
                child: Container(),
              ),
              Expanded(
                  flex: 2,
                  child: BlocBuilder<AuthBloc, AuthState>(
                    builder: (ctx, state) => Column(
                      children: [
                        _buildLoginButton(ctx, state is AuthenticatingState)
                      ],
                    ),
                  )),
            ],
          ),
        ));
  }
}
