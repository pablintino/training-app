import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';
import 'package:training_app/models/workout_models.dart';
import 'package:training_app/utils/known_constants.dart';
import 'package:training_app/widgets/two_letters_icon.dart';

class WorkoutSessionWeekWidget extends StatelessWidget {
  final List<WorkoutSession> weekSessions;
  final Function(bool)? onDragStatusChange;
  final Function(WorkoutSession?)? onDragAccept;
  final Function(WorkoutSession?)? onDragShouldAccept;
  final Function(WorkoutSession)? onTap;
  final bool enableDragAndDrop;

  const WorkoutSessionWeekWidget(this.weekSessions, this.enableDragAndDrop,
      {Key? key,
      this.onDragStatusChange,
      this.onDragAccept,
      this.onDragShouldAccept,
      this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
      child: ExpansionTileCard(
        initialElevation: 5.0,
        elevation: 5.0,
        title: Text('Week ${weekSessions.elementAt(0).week}'),
        children: <Widget>[
          const Divider(
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
    return ScrollConfiguration(
        behavior: const _ClampingScrollBehavior(),
        child: ListView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          itemBuilder: enableDragAndDrop
              ? _dragAndDropItemBuilder
              : _staticListItemBuilder,
          // When drag&drop is enable drop targets must be added, hence the *2 + 1
          // To preserve positions and avoid see tiles changing positions (drag
          // targets are 1px height but its noticeable) "dummy" containers are
          // used when drag and drop is disabled too
          itemCount: weekSessions.length * 2 + 1,
        ));
  }

  Widget _dragAndDropItemBuilder(BuildContext context, int index) {
    return index % 2 == 0
        ? _buildDragTargets(context, index)
        : _buildDraggableSessionItem(
            context, weekSessions.elementAt((index - 1) ~/ 2));
  }

  Widget _staticListItemBuilder(BuildContext context, int index) {
    return index % 2 == 0
        // Empty container of the same size of drag&drop targets
        ? Container(
            height: 1,
            width: 50,
          )
        : _buildSessionCard(context, weekSessions.elementAt((index - 1) ~/ 2));
  }

  Widget _buildDragTargets(BuildContext context, int index) {
    return DragTarget<WorkoutSession>(
//      builder responsible to build a widget based on whether there is an item being dropped or not
      builder: (context, candidates, rejects) {
        return candidates.length > 0
            ? _buildDraggableSessionItem(context, candidates[0]!)
            : Container(
                width: 50,
                height: 1,
              );
      },
//      condition on to accept the item or not
      onWillAccept: (value) => onDragShouldAccept?.call(value) ?? false,
//      what to do when an item is accepted
      onAccept: (value) => onDragAccept?.call(value),
    );
  }

  Widget _buildDraggableSessionItem(
      BuildContext buildContext, WorkoutSession session) {
    // LayoutBuilder needed to pass width to child
    return LayoutBuilder(
      builder: (context, constraints) => LongPressDraggable<WorkoutSession>(
        data: session,
        onDragStarted: () => onDragStatusChange?.call(true),
        onDragEnd: (_) => onDragStatusChange?.call(false),
        onDraggableCanceled: (_, __) => onDragStatusChange?.call(false),
        feedback: Container(
          width: constraints.maxWidth,
          child: _buildSessionCard(buildContext, session),
        ),
        childWhenDragging: Card(
          elevation: 2,
          color: Colors.grey.shade50,
          child: ListTile(),
        ),
        child: _buildSessionCard(buildContext, session),
      ),
    );
  }

  Card _buildSessionCard(BuildContext buildContext, WorkoutSession session) {
    final sessionDay = getDayNameFromInt(session.weekDay);
    return Card(
      elevation: 3,
      child: ListTile(
        leading: TwoLettersIcon(
          sessionDay,
          factor: 0.7,
        ),
        title: Text(
          sessionDay,
          style: const TextStyle(
            fontSize: 15,
          ),
        ),
        onTap: () => onTap?.call(session),
      ),
    );
  }
}

class _ClampingScrollBehavior extends ScrollBehavior {
  const _ClampingScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      ClampingScrollPhysics();
}
