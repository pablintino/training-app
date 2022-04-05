import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:training_app/models/workout_models.dart';
import 'package:training_app/widgets/workout_session_detail_screen_widget/bloc/workout_session_details_bloc.dart';
import 'dart:math';

class WorkoutSessionScreenWidgetArguments {
  final int sessionId;

  WorkoutSessionScreenWidgetArguments(this.sessionId);
}

class WorkoutSessionScreenWidget extends StatefulWidget {
  const WorkoutSessionScreenWidget({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _WorkoutSessionScreenWidgetState();
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

class MyCustomClipper extends CustomClipper<Rect> {
  final double clipHeight;

  MyCustomClipper({required this.clipHeight});

  @override
  getClip(Size size) {
    double top = max(size.height - clipHeight, 0);
    Rect rect = Rect.fromLTRB(0.0, top, size.width, size.height);
    return rect;
  }

  @override
  bool shouldReclip(CustomClipper oldClipper) {
    return false;
  }
}

class _WorkoutSessionScreenWidgetState
    extends State<WorkoutSessionScreenWidget> {
  @override
  Widget build(BuildContext context) {
    final List<String> _tabs = <String>['Tab 1', 'Tab 2'];
    final args = ModalRoute.of(context)!.settings.arguments
        as WorkoutSessionScreenWidgetArguments;
    return Scaffold(
        body: SafeArea(
      child: BlocProvider<WorkoutSessionDetailsBloc>(
        create: (_) =>
            WorkoutSessionDetailsBloc()..add(LoadSessionEvent(args.sessionId)),
        child:
            BlocBuilder<WorkoutSessionDetailsBloc, WorkoutSessionDetailsState>(
                builder: (ctx, state) => state is SessionLoadedState
                    ? _buildScroll(ctx, state, _tabs)
                    : const Center(
                        child: Text('No data'),
                      )),
      ),
    ));
  }

  Widget _buildScroll(
      BuildContext context, SessionLoadedState state, List<String> tabs) {
    return DefaultTabController(
        length: 2,
        child: NestedScrollView(
          // controller: _scrollController,
          headerSliverBuilder: (scrollContext, innerBoxIsScrolled) =>
              _getAppBar(scrollContext, state, tabs, innerBoxIsScrolled),
          body: _buildBody(state),
        ));
  }

  Widget _buildBody(SessionLoadedState state) {
    final sortedList = List.from(state.workoutSession.phases);
    sortedList.sort((a, b) => ((a.sequence != null && b.sequence != null)
        ? (a.sequence! - b.sequence!)
        : 0));
    return ClipRect(
      clipper: MyCustomClipper(
          clipHeight: MediaQuery.of(context).size.height -
              (kToolbarHeight + 46 + MediaQuery.of(context).padding.top)),
      // TODO YAPA appbar size + tabs + safe area margin (the mobile appbar)
      child: TabBarView(
        children: [
          ListView.builder(
            key: new PageStorageKey('myListView'),
            shrinkWrap: true,
            physics: ClampingScrollPhysics(),
            itemBuilder: (_, idx) => _PhaseContainerWidget(
              sortedList[idx],
              key: PageStorageKey('tile$idx'),
            ),
            itemCount: state.workoutSession.phases.length,
          ),
          Center(
            child: Text('Other section'),
          )
        ],
      ),
    );
  }

  List<Widget> _getAppBar(BuildContext context, SessionLoadedState state,
      List<String> tabs, bool innerBoxIsScrolled) {
    if (innerBoxIsScrolled) {
      //  print(_scrollController?.position);
    }

    final headerText =
        'Session: ${_getDayName(state.workoutSession.weekDay)} ${state.workoutSession.week ?? ''}';
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
          title: Text(headerText),
          centerTitle: true,
        ),
        //title: const Text('Session'),
        //leading: Icon(Icons.arrow_back),
        //actions: [
        //  Icon(Icons.settings),
        //  SizedBox(width: 12),
        //],
      ),
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

  static String _getDayName(int? day) {
    switch (day) {
      case 0:
        return 'Monday';
      case 1:
        return 'Tuesday';
      case 2:
        return 'Wednesday';
      case 3:
        return 'Thursday';
      case 4:
        return 'Friday';
      case 5:
        return 'Saturday';
      case 6:
        return 'Sunday';
    }
    return '';
  }
}

class _PhaseContainerWidget extends StatefulWidget {
  final WorkoutPhase workoutPhase;

  const _PhaseContainerWidget(this.workoutPhase, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TestCardState();
}

class _DummyIcon extends StatelessWidget {
  final int number;

  const _DummyIcon(this.number, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      //width: 50.0,
      //height: 50.0,
      padding: const EdgeInsets.all(15.0),
      decoration: new BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey,
      ),
      child: new Text(number.toString(),
          style: new TextStyle(color: Colors.white, fontSize: 20.0)),
    );
  }
}

class _TestCardState extends State<_PhaseContainerWidget> {
  @override
  Widget build(BuildContext context) {
    final sortedList = List<WorkoutItem>.from(widget.workoutPhase.items);
    sortedList.sort((a, b) => ((a.sequence != null && b.sequence != null)
        ? (a.sequence! - b.sequence!)
        : 0));
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: ExpansionTileCard(
        initialElevation: 5.0,
        elevation: 5.0,
        leading: widget.workoutPhase.sequence != null
            ? _DummyIcon(widget.workoutPhase.sequence!)
            : null,
        title: Text(widget.workoutPhase.name ?? 'No name'),
        children: <Widget>[
          Divider(
            thickness: 1.0,
            height: 1.0,
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 8.0,
              ),
              child: _buildItemList(context, sortedList),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemList(
      BuildContext buildContext, List<WorkoutItem> workoutItems) {
    bool editMode = false;
    return editMode
        ? ReorderableListView.builder(
            onReorder: (int oldIndex, int newIndex) {
              setState(() {
                /* if (oldIndex < newIndex) {
            newIndex -= 1;
          }
          final int item = _items.removeAt(oldIndex);
          _items.insert(newIndex, item);*/
                //TODO
              });
            },
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int index) =>
                _buildItem(context, workoutItems[index]),
            itemCount: workoutItems.length,
          )
        : Column(
            children: workoutItems.map((e) => _buildItem(context, e)).toList(),
          );
  }

  Widget _buildItem(BuildContext buildContext, WorkoutItem workoutItem) {
    return Padding(
      key: Key('${workoutItem.id!}'),
      padding: EdgeInsets.symmetric(vertical: 0),
      child: Card(
        //shape: RoundedRectangleBorder(
        //  borderRadius: BorderRadius.circular(5),
        //side: BorderSide(
        //color: Colors.black,
        //),
        //),
        elevation: 2,
        //shadowColor: Colors.red,
        child: Column(
          children: [
            Container(
              //height: 40,
              child: ListTileTheme(
                tileColor: Theme.of(context).primaryColor.withOpacity(0.3),
                child: ListTile(
                  //leading: const Icon(Icons.flight_land),
                  title: Text(
                    workoutItem.name ?? 'No name',
                    style: TextStyle(
                      fontSize: 15,
                      //COLOR DEL TEXTO TITULO
                      //color: Colors.blueAccent,
                    ),
                  ),
                  //subtitle: Text(
                  //  'Sub Title',
                  //),
                  //trailing: const Icon(Icons.drag_indicator),
                ),
              ),
            ),
            //Divider(),
            _buildItemDetails(buildContext, workoutItem)
          ],
        ),
      ),
    );
  }

  Container _buildItemDetails(
      BuildContext buildContext, WorkoutItem workoutItem) {
    final itemDetails = _buildWorkoutItemDetails(workoutItem);
    return Container(
      alignment: AlignmentDirectional.centerStart,
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (itemDetails != null) itemDetails,
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5),
            child: IntrinsicWidth(
              // Give the column the width of its largest child (determined by each row Wrap)
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: _buildExercisesDetailsList(workoutItem),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget? _buildWorkoutItemDetails(WorkoutItem workoutItem) {
    String itemDetails = '';
    if (workoutItem.rounds != null) {
      itemDetails = itemDetails + 'Rounds: ${workoutItem.rounds}';
    }
    if (workoutItem.timeCapSecs != null) {
      itemDetails =
          itemDetails + '\nTime cap: ${workoutItem.timeCapSecs} (secs)';
    }
    if (workoutItem.workTimeSecs != null) {
      itemDetails =
          itemDetails + '\nTime work: ${workoutItem.workTimeSecs} (secs)';
    }
    if (workoutItem.restTimeSecs != null) {
      itemDetails =
          itemDetails + '\nTime rest: ${workoutItem.restTimeSecs} (secs)';
    }
    if (workoutItem.workModality != null &&
        workoutItem.workModality!.isNotEmpty) {
      itemDetails = itemDetails + '\nModality: ${workoutItem.workModality}';
    }
    return itemDetails != ''
        ? Padding(
            padding: EdgeInsets.symmetric(vertical: 5),
            child: Text(itemDetails))
        : null;
  }

  List<Widget> _buildExercisesDetailsList(WorkoutItem workoutItem) {
    final oddBackgroundColor = Theme.of(context).primaryColor.withOpacity(0.2);
    final evenBackgroundColor = Theme.of(context).primaryColor.withOpacity(0.1);

    List<Widget> exercisesWidgets = [];
    final sortedSets = List<WorkoutSet>.from(workoutItem.sets);
    sortedSets.sort((a, b) => ((a.sequence != null && b.sequence != null)
        ? (a.sequence! - b.sequence!)
        : 0));
    int rows = 0;
    int index = 0;
    while (index < sortedSets.length) {
      int lastEquals = _getLastEqualExerciseIndex(sortedSets, index);
      final exerciseExecutionsDetails = [
        for (var i = index; i <= lastEquals; i += 1) i
      ].map((e) => _buildSetRepsWeightTest(sortedSets[e])).toList();
      exercisesWidgets.add(_buildSetDetailsRowWidget(
          sortedSets[index],
          exerciseExecutionsDetails,
          rows % 2 == 0 ? oddBackgroundColor : evenBackgroundColor));

      //Update index
      if (lastEquals + 1 == index) {
        break;
      } else {
        index = lastEquals + 1;
      }
      rows++;
    }
    return exercisesWidgets;
  }

  Container _buildSetDetailsRowWidget(WorkoutSet workoutSet,
      List<Text> exerciseExecutionsDetails, Color backgroundColor) {
    return Container(
      color: backgroundColor,
      padding: EdgeInsets.symmetric(vertical: 3),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 5),
        child: IntrinsicHeight(
            child: Wrap(
          children: [
            Text(
              workoutSet.exercise?.name ?? 'Unknown exercise',
              textAlign: TextAlign.start,
            ),
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: exerciseExecutionsDetails),
            ),
          ],
        )),
      ),
    );
  }

  int _getLastEqualExerciseIndex(
      final List<WorkoutSet> workoutSets, final int startIndex) {
    int lastIndex = startIndex;
    while (lastIndex < workoutSets.length) {
      if (lastIndex + 1 < workoutSets.length &&
          workoutSets[lastIndex].exerciseId ==
              workoutSets[lastIndex + 1].exerciseId) {
        lastIndex = lastIndex + 1;
      } else {
        break;
      }
    }
    return lastIndex;
  }

  Text _buildSetRepsWeightTest(WorkoutSet workoutSet) {
    final String weight =
        workoutSet.weight != null ? '${workoutSet.weight} Kg' : '';
    final String distance =
        workoutSet.distance != null ? '${workoutSet.distance} m' : '';
    String reps = '';
    if (workoutSet.setExecutions != null && workoutSet.reps != null) {
      reps = '${workoutSet.reps}x ${workoutSet.setExecutions}';
    } else if (workoutSet.setExecutions != null || workoutSet.reps != null) {
      reps = 'x${workoutSet.setExecutions ?? workoutSet.reps}';
    }

    return Text('$reps $weight $distance');
  }
}
