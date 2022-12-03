import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:training_app/models/workout_models.dart';
import 'package:training_app/utils/known_constants.dart';
import 'package:training_app/widgets/two_letters_icon.dart';

class WorkoutSessionWeekWidget extends StatelessWidget {
  final List<WorkoutSession> weekSessions;
  final Function(bool)? onDragStatusChange;
  final Function(WorkoutSession, int week, int day)? onDragAccept;
  final Function(WorkoutSession?, int week, int day)? onDragShouldAccept;
  final Function(WorkoutSession)? onTap;
  final bool enableDragAndDrop;
  final int week;

  const WorkoutSessionWeekWidget(
      this.weekSessions, this.enableDragAndDrop, this.week,
      {Key? key,
      this.onDragStatusChange,
      this.onDragAccept,
      this.onDragShouldAccept,
      this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text('Week ${weekSessions.elementAt(0).week}'),
          ),
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
          )
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
            // If editing total elements are the total number of days in a week
            itemCount: enableDragAndDrop ? 7 : weekSessions.length));
  }

  Widget _dragAndDropItemBuilder(BuildContext context, int index) {
    final day = index + 1; // Days are in 1 to 7 range
    final sessionForIndex =
        weekSessions.firstWhereOrNull((element) => element.weekDay == day);
    return sessionForIndex == null
        ? _buildDragTargets(context, day)
        : _buildDraggableSessionItem(context, sessionForIndex);
  }

  Widget _staticListItemBuilder(BuildContext context, int index) {
    return _buildSessionCard(context, weekSessions.elementAt(index));
  }

  Widget _buildDragTargets(BuildContext context, int day) {
    return DragTarget<WorkoutSession>(
//      builder responsible to build a widget based on whether there is an item being dropped or not
      builder: (context, candidates, rejects) {
        return candidates.length > 0
            ? _buildSessionCard(context, candidates[0]!, day: day)
            : Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(2)),
                ),
                child: ListTile(
                  title: Center(
                    child: Text(
                      getDayNameFromInt(day),
                      style: TextStyle(
                          color: Colors.grey, fontStyle: FontStyle.italic),
                    ),
                  ),
                ),
              );
      },
//      condition on to accept the item or not
      onWillAccept: (value) =>
          onDragShouldAccept?.call(value, week, day) ?? false,
//      what to do when an item is accepted
      onAccept: (value) => onDragAccept?.call(value, week, day),
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
        onDragCompleted: () => onDragStatusChange?.call(false),
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

  Card _buildSessionCard(BuildContext buildContext, WorkoutSession session,
      {int? day}) {
    final sessionDay = getDayNameFromInt(day ?? session.weekDay);
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
