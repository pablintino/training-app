import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:training_app/models/workout_models.dart';
import 'package:training_app/utils/known_constants.dart';
import 'package:training_app/widgets/custom_height_rect_clipper.dart';
import 'package:training_app/widgets/workout_session_detail_screen_widget/bloc/workout_session_details_bloc.dart';
import 'package:training_app/widgets/workout_session_detail_screen_widget/workout_phases_list_widget.dart';

class WorkoutSessionScreenWidgetArguments {
  final int sessionId;

  WorkoutSessionScreenWidgetArguments(this.sessionId);
}

class WorkoutSessionScreenWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final List<String> _tabs = <String>['Phases', 'Media'];
    final args = ModalRoute.of(context)!.settings.arguments
        as WorkoutSessionScreenWidgetArguments;
    return Scaffold(
        body: SafeArea(
      child: BlocProvider<WorkoutSessionDetailsBloc>(
        create: (_) =>
            WorkoutSessionDetailsBloc()..add(LoadSessionEvent(args.sessionId)),
        child:
            BlocBuilder<WorkoutSessionDetailsBloc, WorkoutSessionDetailsState>(
                builder: (ctx, state) => DefaultTabController(
                    length: 2,
                    child: NestedScrollView(
                      // controller: _scrollController,
                      headerSliverBuilder:
                          (scrollContext, innerBoxIsScrolled) => _getAppBar(
                              scrollContext, state, _tabs, innerBoxIsScrolled),
                      body: _buildBody(context, state),
                    ))),
      ),
    ));
  }

  Widget _buildBody(BuildContext context, WorkoutSessionDetailsState state) {
    double baseClipHeight = MediaQuery.of(context).size.height -
        (kToolbarHeight + MediaQuery.of(context).padding.top);
    if (state is SessionLoadedState) {
      return ClipRect(
        clipper: CustomHeightClipper(
          baseClipHeight - 46,
        ), // 46 is the default tabbar height
        child: _buildTabBar(state),
      );
    }
    return ClipRect(
      clipper: CustomHeightClipper(
        baseClipHeight,
      ),
      child: Center(
        child: Text('No data'),
      ),
    );
  }

  TabBarView _buildTabBar(SessionLoadedState state) {
    final sortedList = List<WorkoutPhase>.from(state.workoutSession.phases);
    sortedList.sort((a, b) => ((a.sequence != null && b.sequence != null)
        ? (a.sequence! - b.sequence!)
        : 0));
    return TabBarView(
      children: [
        WorkoutPhasesListWidget(state.workoutSession.phases),
        Center(
          child: Text('Other section'),
        )
      ],
    );
  }

  List<Widget> _getAppBar(
      BuildContext context,
      WorkoutSessionDetailsState state,
      List<String> tabs,
      bool innerBoxIsScrolled) {
    final headerText = state is SessionLoadedState
        ? 'Session: ${getDayNameFromInt(state.workoutSession.weekDay)} ${state.workoutSession.week ?? ''}'
        : null;
    return [
      SliverAppBar(
        automaticallyImplyLeading: true,
        backgroundColor: Theme.of(context).primaryColor,
        expandedHeight: 100,
        pinned: true,
        flexibleSpace: FlexibleSpaceBar(
          //titlePadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          background: Image.network(
            'https://source.unsplash.com/random?monochromatic+dark',
            fit: BoxFit.cover,
          ),
          title: Text(headerText ?? ''),
          centerTitle: true,
        ),
      ),
      if (state is SessionLoadedState)
        SliverPersistentHeader(
          delegate: _SliverAppBarDelegate(
            TabBar(
              labelColor: Colors.black87,
              unselectedLabelColor: Colors.grey,
              // These are the widgets to put in each tab in the tab bar.
              tabs: tabs
                  .map((String name) => Tab(
                        text: name,
                      ))
                  .toList(),
            ),
          ),
          pinned: true,
        )
    ];
  }


}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return new Container(
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
