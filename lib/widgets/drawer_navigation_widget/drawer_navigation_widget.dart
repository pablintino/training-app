import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:training_app/blocs/auth/auth_bloc.dart';

class DrawerNavigationWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authBloc = BlocProvider.of<AuthBloc>(context);
    return Drawer(
      // Add a ListView to the drawer. This ensures the user can scroll
      // through the options in the drawer if there isn't enough vertical
      // space to fit everything.
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: [
          BlocBuilder<AuthBloc, AuthState>(
              bloc: authBloc, builder: (_, state) => _buildHeader(state)),
          ListTile(
            title: const Text('Exercises'),
            onTap: () {
              Navigator.of(context).pushNamed('/exercises');
            },
          ),
          ListTile(
            title: const Text('Item 2'),
            onTap: () {
              // Update the state of the app.
              // ...
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              authBloc.add(LogoutAuthEvent());
            },
          ),
        ],
      ),
    );
  }

  UserAccountsDrawerHeader _buildHeader(AuthState state) {
    final String picture = state is AuthenticatedState
        ? state.userInfo.picture ??
            'https://visualpharm.com/assets/908/User-595b40b85ba036ed117dc597.svg'
        : 'https://visualpharm.com/assets/908/User-595b40b85ba036ed117dc597.svg';
    final String userName =
        state is AuthenticatedState ? state.userInfo.nickname ?? '' : '';
    final String email =
        state is AuthenticatedState ? state.userInfo.email ?? '' : '';
    return UserAccountsDrawerHeader(
      decoration: BoxDecoration(
        color: Colors.blue,
      ),
      currentAccountPicture: Container(
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
                fit: BoxFit.fill, image: NetworkImage(picture))),
      ),
      accountEmail: Text(email),
      accountName: Text(userName),
    );
  }
}
