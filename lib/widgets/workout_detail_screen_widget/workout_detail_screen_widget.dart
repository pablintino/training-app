import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:training_app/app_routes.dart';
import 'package:training_app/models/workout_models.dart';
import 'package:training_app/widgets/two_letters_icon/two_letters_icon.dart';
import 'package:training_app/widgets/workout_detail_screen_widget/bloc/workout_details_bloc.dart';
import 'package:training_app/widgets/workout_session_detail_screen_widget/workout_session_detail_screen_widget.dart';

class WorkoutScreenWidgetArguments {
  final int workoutId;

  WorkoutScreenWidgetArguments(this.workoutId);
}

class WorkoutDetailsScreenWidget extends StatelessWidget {
  const WorkoutDetailsScreenWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments
        as WorkoutScreenWidgetArguments;
    return Scaffold(
        //appBar: AppBar(title: const Text(_title)),
        body: BlocProvider<WorkoutDetailsBloc>(
      create: (_) =>
          WorkoutDetailsBloc()..add(LoadWorkoutEvent(args.workoutId)),
      child: BlocBuilder<WorkoutDetailsBloc, WorkoutDetailsState>(
          builder: (ctx, state) => state is WorkoutLoadedState
              ? CustomScrollView(
                  slivers: [
                    _getAppBar(ctx, state),
                    ..._buildBody(ctx, state),
                  ],
                )
              : const Center(
                  child: Text('No data'),
                )),
    ));
  }

  SliverAppBar _getAppBar(BuildContext context, WorkoutLoadedState state) {
    return SliverAppBar(
      automaticallyImplyLeading: true,
      backgroundColor: Theme.of(context).primaryColor,
      expandedHeight: 150,
      floating: true,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        //titlePadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        background: Image.network(
          'https://source.unsplash.com/random?monochromatic+dark',
          fit: BoxFit.cover,
        ),
        title: Text(state.workout.name!),
        //centerTitle: true,
      ),
      //title: const Text('Session'),
      // leading: IconButton(
      //   icon: Icon(Icons.arrow_back),
      //   onPressed: () => Navigator.pop(context),
      // ),
      //actions: [
      //  Icon(Icons.settings),
      //  SizedBox(width: 12),
      //],
    );
  }

  List<Widget> _buildBody(BuildContext context, WorkoutLoadedState state) {
    Map<int, List<WorkoutSession>> groupedSessions = {};
    for (WorkoutSession workoutSession in state.workout.sessions) {
      if (!groupedSessions.containsKey(workoutSession.week)) {
        // TODO Review !
        groupedSessions[workoutSession.week!] = [];
      }
      groupedSessions[workoutSession.week!]!.add(workoutSession);
    }

    /*
    sortedList.sort((a, b) => (((a.weekDay != null && b.weekDay != null) &&
            (a.week != null && b.week != null))
        ? ((a.week! * 10 + a.weekDay!) - (b.week! * 10 + b.weekDay!))
        : 0));
    */
    return [
      SliverList(
          delegate: SliverChildListDelegate([
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
          child: TextFormField(
            enabled: false,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: state.workout.name!,
            ),
            initialValue: state.workout.name!,
            style: TextStyle(fontSize: 25.0),
            textAlign: TextAlign.left,
          ),
        ),
        state.workout.description != null
            ? Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                child: TextFormField(
                  enabled: false,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: state.workout.description,
                  ),
                  initialValue: state.workout.description,
                  style: TextStyle(fontSize: 15.0),
                  maxLines: 3,
                  textAlign: TextAlign.left,
                ),
              )
            : Container(),  // TODO Review a better way
        PreferredSize(
          preferredSize:
              Size(double.infinity, MediaQuery.of(context).size.height / 6),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                Container(
                  alignment: AlignmentDirectional.topStart,
                  child: Text(
                    'Sessions',
                    style: TextStyle(fontSize: 18.0),
                    textAlign: TextAlign.left,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width - 50,
                      child: Divider(
                        thickness: 1,
                        color: Colors.blue.withOpacity(0.5),
                      ),
                    ),
                    Expanded(child: Container())
                  ],
                )
              ],
            ),
          ),
        ),
      ])),
      SliverList(
          delegate: SliverChildBuilderDelegate(
        (_, idx) => _WeekSessionsCardWidget(
            groupedSessions[groupedSessions.keys.elementAt(idx)]!),
        childCount: groupedSessions.keys.length,
      ))
    ];
  }
}

class _WeekSessionsCardWidget extends StatefulWidget {
  final List<WorkoutSession> weekSessions;

  const _WeekSessionsCardWidget(this.weekSessions, {Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _WeekSessionsCardWidgetState();
}

class _WeekSessionsCardWidgetState extends State<_WeekSessionsCardWidget> {
  final GlobalKey<ExpansionTileCardState> cardA = new GlobalKey();

  @override
  Widget build(BuildContext context) {
    final ButtonStyle flatButtonStyle = TextButton.styleFrom(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(4.0)),
      ),
    );
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: ExpansionTileCard(
        leading: TwoLettersIcon('${widget.weekSessions.elementAt(0).week}'),
        initialElevation: 5.0,
        elevation: 5.0,
        title: Text('Week ${widget.weekSessions.elementAt(0).week}'),
        //subtitle: Text('I expand, too!'),
        children: <Widget>[
          Divider(
            thickness: 1.0,
            height: 1.0,
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: _buildList(context),
            ),
          ),
          ButtonBar(
            alignment: MainAxisAlignment.spaceAround,
            buttonHeight: 52.0,
            buttonMinWidth: 90.0,
            children: <Widget>[
              TextButton(
                style: flatButtonStyle,
                onPressed: () {
                  cardA.currentState?.collapse();
                },
                child: Column(
                  children: <Widget>[
                    const Icon(Icons.delete, color: Colors.red),
                    const Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                    ),
                    const Text(
                      'Close',
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
              TextButton(
                style: flatButtonStyle,
                onPressed: () {
                  cardA.currentState?.toggleExpansion();
                },
                child: Column(
                  children: <Widget>[
                    Icon(Icons.add),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                    ),
                    Text('Add'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext buildContext) {
    return ReorderableListView.builder(
      onReorder: (int oldIndex, int newIndex) {
        setState(() {
          if (oldIndex < newIndex) {
            newIndex -= 1;
          }
          final WorkoutSession session = widget.weekSessions.removeAt(oldIndex);
          widget.weekSessions.insert(newIndex, session);
        });
      },
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemBuilder: (BuildContext context, int index) {
        return Padding(
          key: Key('$index'),
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
            child: ListTile(
              //leading: const Icon(Icons.flight_land),
              title: Text(
                'Day ${widget.weekSessions.elementAt(index).weekDay}',
                style: TextStyle(
                  fontSize: 15,
                  //COLOR DEL TEXTO TITULO
                  //color: Colors.blueAccent,
                ),
              ),
              //subtitle: Text(
              //  'Sub Title',
              //),
              trailing: const Icon(Icons.drag_indicator),
              onTap: () {
                Navigator.pushNamed(
                    context, AppRoutes.WORKOUTS_SESSIONS_DETAILS_SCREEN_ROUTE,
                    arguments: WorkoutSessionScreenWidgetArguments(
                        widget.weekSessions.elementAt(index).id!));
              },
            ),
          ),
        );
      },
      itemCount: widget.weekSessions.length,
    );
  }
}
