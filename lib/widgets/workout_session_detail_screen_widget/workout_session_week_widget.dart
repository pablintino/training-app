
import 'package:flutter/material.dart';
import 'package:training_app/app_routes.dart';
import 'package:training_app/utils/known_constants.dart';

class _WeekSessionsCardWidget extends StatefulWidget {
  final List<WorkoutSession> weekSessions;
  final ScrollController scroller;

  const _WeekSessionsCardWidget(this.weekSessions, this.scroller, {Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _WeekSessionsCardWidgetState();
}

class _WeekSessionsCardWidgetState extends State<_WeekSessionsCardWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
      child: ExpansionTileCard(
        initialElevation: 5.0,
        elevation: 5.0,
        title: Text('Week ${widget.weekSessions.elementAt(0).week}'),
        children: <Widget>[
          Divider(
            thickness: 1.0,
            height: 1.0,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 10.0,
              vertical: 5.0,
            ),
            child: _buildList(context),
          ),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext buildContext) {
    final week = widget.weekSessions.elementAt(0).week!;
    return ScrollConfiguration(
        behavior: _ClampingScrollBehavior(),
        child: ListView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          itemBuilder: (BuildContext context, int index) {
            if (index % 2 == 0) {
              return _buildDragTargets(context, index, week);
            } else {
              return _buildDraggableSessionItem(buildContext,
                  widget.weekSessions.elementAt((index - 1) ~/ 2));
            }
          },
          itemCount: widget.weekSessions.length * 2 + 1,
        ));
  }

  Widget _buildDragTargets(BuildContext context, int index, int week) {
    return DragTarget<WorkoutSession>(
//      builder responsible to build a widget based on whether there is an item being dropped or not
      builder: (context, candidates, rejects) {
        return candidates.length > 0
            ? _buildDraggableSessionItem(context, candidates[0]!)
            : Container(
          width: 5,
          height: 5,
        );
      },
//      condition on to accept the item or not
      //onWillAccept: (value)=>!listA.contains(value),
      onWillAccept: (value) => true,
//      what to do when an item is accepted
      onAccept: (value) {
        print('test');
        // setState(() {
        //  listA.insert(index + 1, value);
        //  listB.remove(value);
        //  });
      },
    );
  }

  Widget _buildDraggableSessionItem(
      BuildContext buildContext, WorkoutSession session) {
    final sessionDay = getDayNameFromInt(session.weekDay);
    final bloc = BlocProvider.of<WorkoutDetailsBloc>(context);
    // LayoutBuilder needed to pass width to child
    return LayoutBuilder(
      builder: (context, constraints) => LongPressDraggable<WorkoutSession>(
        data: session,
        onDragStarted: () => bloc.add(UpdateDraggingStateEvent(true)),
        onDragEnd: (details) => bloc.add(UpdateDraggingStateEvent(false)),
        onDraggableCanceled: (velocity, offset) =>
            bloc.add(UpdateDraggingStateEvent(false)),
        feedback: Container(
          width: constraints.maxWidth,
          child: _buildSessionCard(sessionDay, session),
        ),
        childWhenDragging: Card(
          elevation: 2,
          color: Colors.grey.shade50,
          child: ListTile(),
        ),
        child: _buildSessionCard(sessionDay, session),
      ),
    );
  }

  Card _buildSessionCard(String sessionDay, WorkoutSession session) {
    return Card(
      elevation: 3,
      child: ListTile(
        leading: TwoLettersIcon(
          sessionDay,
          factor: 0.7,
        ),
        title: Text(
          sessionDay,
          style: TextStyle(
            fontSize: 15,
          ),
        ),
        onTap: () {
          Navigator.pushNamed(
              context, AppRoutes.WORKOUTS_SESSIONS_DETAILS_SCREEN_ROUTE,
              arguments: WorkoutSessionScreenWidgetArguments(session.id!));
        },
      ),
    );
  }
}

class _ClampingScrollBehavior extends ScrollBehavior {
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      ClampingScrollPhysics();
}