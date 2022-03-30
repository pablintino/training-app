import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:training_app/models/workout_models.dart';
import 'package:training_app/widgets/workout_session_detail_screen_widget/bloc/workout_session_details_bloc.dart';

class WorkoutSessionScreenWidget extends StatelessWidget {
  const WorkoutSessionScreenWidget({Key? key}) : super(key: key);

  static const String _title = 'Session details';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(_title)),
      body: BlocProvider<WorkoutSessionDetailsBloc>(
        create: (_) => WorkoutSessionDetailsBloc()..add(LoadSessionEvent(7)),
        child: _ScrollableSessionViewWidget(),
      ),
    );
  }
}

class _ScrollableSessionViewWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ScrollableSessionViewWidgetState();
}

class _ScrollableSessionViewWidgetState
    extends State<_ScrollableSessionViewWidget>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      headerSliverBuilder: _getHeaderBuilder(),
      body: Padding(
          padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
          child: BlocBuilder<WorkoutSessionDetailsBloc,
              WorkoutSessionDetailsState>(builder: (_, state) {
            if (state is SessionLoadedState) {
              final sortedList = List.from(state.workoutSession.phases);
              sortedList.sort((a, b) =>
                  ((a.sequence != null && b.sequence != null)
                      ? (a.sequence! - b.sequence!)
                      : 0));
              return ListView.builder(
                itemBuilder: (_, idx) => _PhaseContainerWidget(sortedList[idx]),
                itemCount: state.workoutSession.phases.length,
              );
            }
            return Center(
              child: Text('No data'),
            );
          })),
    );
  }

  NestedScrollViewHeaderSliversBuilder _getHeaderBuilder() {
    return (BuildContext context, bool innerBoxIsScrolled) => [
          SliverAppBar(
            automaticallyImplyLeading: false,
            pinned: false,
            backgroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  BlocBuilder<WorkoutSessionDetailsBloc,
                      WorkoutSessionDetailsState>(builder: (context, state) {
                    final loadedState =
                        (state is SessionLoadedState) ? state : null;

                    final headerText =
                        'Week ${loadedState?.workoutSession?.week ?? ''} - Day ${loadedState?.workoutSession?.weekDay ?? ''}';
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 10),
                      child: TextFormField(
                        enabled: false,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: headerText,
                        ),
                        initialValue: headerText,
                        style: TextStyle(fontSize: 25.0),
                        textAlign: TextAlign.left,
                      ),
                    );
                  }),
                ],
              ),
            ),
            bottom: PreferredSize(
              preferredSize: Size(
                  double.infinity, MediaQuery.of(context).size.height / 10),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    Container(
                      alignment: AlignmentDirectional.topStart,
                      child: const Text(
                        'Phases',
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
          )
        ];
  }
}

class _PhaseContainerWidget extends StatefulWidget {
  final WorkoutPhase workoutPhase;

  const _PhaseContainerWidget(this.workoutPhase, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TestCardState();
}

class _TestCardState extends State<_PhaseContainerWidget> {
  final GlobalKey<ExpansionTileCardState> cardA = new GlobalKey();

  @override
  Widget build(BuildContext context) {
    final ButtonStyle flatButtonStyle = TextButton.styleFrom(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(4.0)),
      ),
    );

    final sortedList = List<WorkoutItem>.from(widget.workoutPhase.items);
    sortedList.sort((a, b) => ((a.sequence != null && b.sequence != null)
        ? (a.sequence! - b.sequence!)
        : 0));
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: ExpansionTileCard(
        initialElevation: 5.0,
        elevation: 5.0,
        title: Text(widget.workoutPhase.name ?? 'No name'),
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
                horizontal: 8.0,
                vertical: 8.0,
              ),
              child: _buildItemList(context, sortedList),
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
                  trailing: const Icon(Icons.drag_indicator),
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
    return Container(
      //decoration: BoxDecoration(color: Colors.tealAccent.withOpacity(0.5)),
      alignment: AlignmentDirectional.centerStart,
      child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWorkoutItemDetails(workoutItem),
              ..._buildExercisesDetailsList(workoutItem),
            ],
          )),
    );
  }

  Widget _buildWorkoutItemDetails(WorkoutItem workoutItem) {
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
    return itemDetails != '' ? Text(itemDetails) : Container();
  }

  List<Widget> _buildExercisesDetailsList(WorkoutItem workoutItem) {
    List<Widget> exercisesWidgets = [];
    int index = 0;

    final sortedSets = List<WorkoutSet>.from(workoutItem.sets);
    sortedSets.sort((a, b) => ((a.sequence != null && b.sequence != null)
        ? (a.sequence! - b.sequence!)
        : 0));

    while (index < sortedSets.length) {
      int lastEquals = _getLastEqualExerciseIndex(sortedSets, index);
      final exerciseExecutionsDetails = [
        for (var i = index; i <= lastEquals; i += 1) i
      ].map((e) => _buildSetRepsWeightTest(sortedSets[e])).toList();
      final widget = Container(
        padding: EdgeInsets.symmetric(vertical: 3),
        child: IntrinsicHeight(
            child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              sortedSets[index].exercise?.name ?? 'Unknown exercise',
              textAlign: TextAlign.start,
            ),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: exerciseExecutionsDetails)),
          ],
        )),
      );
      exercisesWidgets.add(widget);

      //Update index
      if (lastEquals + 1 == index) {
        break;
      } else {
        index = lastEquals + 1;
      }
    }
    return exercisesWidgets;
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
