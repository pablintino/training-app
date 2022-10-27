import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:training_app/widgets/home_screen_widget/bloc/home_screen_bloc.dart';
import 'package:training_app/widgets/home_screen_widget/home_screen_constants.dart';
import 'package:training_app/widgets/drawer_navigation_widget/drawer_navigation_widget.dart';
import 'package:training_app/widgets/workout_list_widget/bloc/workout_list_bloc.dart';
import 'package:training_app/widgets/workout_list_widget/workout_list_widget.dart';

class HomeTabbedWidget extends StatefulWidget {
  const HomeTabbedWidget({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomeTabbedWidgetState();
}

class _HomeTabbedWidgetState extends State<HomeTabbedWidget> {
  final _pageViewController =
      PageController(initialPage: BottomNavigationItem.CurrentSession.index);

  @override
  void dispose() {
    _pageViewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<HomeScreenBloc>(context);
    return BlocBuilder<HomeScreenBloc, BottomNavigationState>(
        builder: (ctx, state) => Scaffold(
              appBar: AppBar(
                title: _buildHeader(state),
              ),
              drawer: DrawerNavigationWidget(),
              body: PageView(
                controller: _pageViewController,
                children: <Widget>[
                  BlocProvider(
                    create: (ctx) =>
                        WorkoutListBloc()..add(WorkoutFetchEvent()),
                    child: WorkoutListWidget(),
                  ),
                  Container(
                    child: Center(
                      child: Text('Current session'),
                    ),
                  ),
                  Container(
                    child: Center(
                      child: Text('Sessions'),
                    ),
                  ),
                ],
                onPageChanged: (index) => bloc.add(
                    BottomNavigationEvent(BottomNavigationItem.values[index])),
              ),
              bottomNavigationBar: BottomNavigationBar(
                items: const <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: Icon(Icons.receipt_long),
                    label: 'Workout',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.edit),
                    label: 'Current Session',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.collections_bookmark),
                    label: 'Sessions',
                  ),
                ],
                currentIndex: state.selectedItem.index,
                selectedItemColor: Colors.amber[800],
                onTap: (index) => _pageViewController.animateToPage(index,
                    duration: Duration(milliseconds: 200),
                    curve: Curves.bounceOut),
              ),
            ));
  }

  Text _buildHeader(BottomNavigationState state) {
    if (state.selectedItem == BottomNavigationItem.Workouts) {
      return const Text('Workout list');
    } else if (state.selectedItem == BottomNavigationItem.CurrentSession) {
      return const Text('Current session');
    } else if (state.selectedItem == BottomNavigationItem.Sessions) {
      return const Text('Session list');
    } else {
      return const Text('Unknown');
    }
  }
}
