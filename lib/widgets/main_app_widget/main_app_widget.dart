import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:training_app/widgets/home_screen_widget/bloc/home_screen_bloc.dart';
import 'package:training_app/widgets/home_screen_widget/home_screen_widget.dart';

class MainAppWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<HomeScreenBloc>(
        create: (_) => HomeScreenBloc(), child: HomeTabbedWidget());
  }
}
