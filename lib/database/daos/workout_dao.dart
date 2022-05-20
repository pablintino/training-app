import 'dart:async';
import 'package:drift/drift.dart';
import 'package:drift/extensions/native.dart';
import 'package:training_app/database/database.dart';
import 'package:training_app/database/join_entities.dart';

part 'workout_dao.g.dart';

@DriftAccessor(tables: [
  Workouts,
  WorkoutSessions,
  WorkoutPhases,
  WorkoutItems,
  WorkoutSets,
  Exercises
])
class WorkoutDAO extends DatabaseAccessor<AppDatabase> with _$WorkoutDAOMixin {
  WorkoutDAO(AppDatabase db) : super(db);

  Future<WorkoutM?> getWorkoutById(int id) =>
      (select(workouts)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<WorkoutM?> getByName(String name) =>
      (select(workouts)..where((tbl) => tbl.name.equals(name)))
          .getSingleOrNull();

  Future insertWorkout(WorkoutsCompanion workoutsCompanion) =>
      into(workouts).insert(workoutsCompanion);

  Future updateWorkoutById(int id, WorkoutsCompanion companion) {
    return (update(workouts)..where((t) => t.id.equals(id))).write(companion);
  }

  Future<WorkoutSessionM?> getWorkoutSessionById(int id) =>
      (select(workoutSessions)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  Future insertWorkoutSession(
          WorkoutSessionsCompanion workoutSessionsCompanion) =>
      into(workoutSessions).insert(workoutSessionsCompanion);

  Future updateWorkoutSessionById(int id, WorkoutSessionsCompanion companion) {
    return (update(workoutSessions)..where((t) => t.id.equals(id)))
        .write(companion);
  }

  Future<WorkoutPhaseM?> getWorkoutPhaseById(int id) =>
      (select(workoutPhases)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future insertWorkoutPhase(WorkoutPhasesCompanion workoutPhasesCompanion) =>
      into(workoutPhases).insert(workoutPhasesCompanion);

  Future updateWorkoutPhaseById(int id, WorkoutPhasesCompanion companion) {
    return (update(workoutPhases)..where((t) => t.id.equals(id)))
        .write(companion);
  }

  Future<WorkoutItemM?> getWorkoutItemById(int id) =>
      (select(workoutItems)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future insertWorkoutItem(WorkoutItemsCompanion workoutItemsCompanion) =>
      into(workoutItems).insert(workoutItemsCompanion);

  Future updateWorkoutItemById(int id, WorkoutItemsCompanion companion) {
    return (update(workoutItems)..where((t) => t.id.equals(id)))
        .write(companion);
  }

  Future<WorkoutSetM?> getWorkoutSetById(int id) =>
      (select(workoutSets)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future insertWorkoutSet(WorkoutSetsCompanion workoutSetsCompanion) =>
      into(workoutSets).insert(workoutSetsCompanion);

  Future updateWorkoutSetById(int id, WorkoutSetsCompanion companion) {
    return (update(workoutSets)..where((t) => t.id.equals(id)))
        .write(companion);
  }

  Future<int> deleteWorkoutById(int id) =>
      (delete(workouts)..where((t) => t.id.equals(id))).go();

  Future<int> deleteWorkoutSessionById(int id) =>
      (delete(workoutSessions)..where((t) => t.id.equals(id))).go();

  Future<int> deleteWorkoutPhaseById(int id) =>
      (delete(workoutPhases)..where((t) => t.id.equals(id))).go();

  Future<int> deleteWorkoutItemById(int id) =>
      (delete(workoutItems)..where((t) => t.id.equals(id))).go();

  Future<int> deleteWorkoutSetById(int id) =>
      (delete(workoutSets)..where((t) => t.id.equals(id))).go();

  Future<List<WorkoutM>> getPagedWorkoutsContainsName(
      int limit, int offset, String name) {
    return (select(workouts)
          ..where((tbl) => tbl.name.containsCase(name, caseSensitive: false))
          ..limit(limit, offset: offset)
          ..orderBy([(t) => OrderingTerm(expression: t.name.lower())]))
        .get();
  }

  Future<List<WorkoutM>> getPagedWorkouts(int limit, int offset) {
    return (select(workouts)
          ..limit(limit, offset: offset)
          ..orderBy([(t) => OrderingTerm(expression: t.name.lower())]))
        .get();
  }

  Future<List<JoinedWorkoutM>> getAllJoinedWorkouts() {
    return (select(workouts))
        .join([
          leftOuterJoin(workoutSessions,
              workoutSessions.workoutId.equalsExp(workouts.id)),
          leftOuterJoin(workoutPhases,
              workoutPhases.workoutSessionId.equalsExp(workoutSessions.id)),
          leftOuterJoin(workoutItems,
              workoutItems.workoutPhaseId.equalsExp(workoutPhases.id)),
          leftOuterJoin(workoutSets,
              workoutSets.workoutItemId.equalsExp(workoutItems.id)),
          leftOuterJoin(
              exercises, exercises.id.equalsExp(workoutSets.exerciseId))
        ])
        .get()
        .then(_mapJoinedWorkouts);
  }

  Future<JoinedWorkoutM?> getJoinedWorkoutById(int id) {
    return (select(workouts)..where((t) => t.id.equals(id)))
        .join([
          leftOuterJoin(workoutSessions,
              workoutSessions.workoutId.equalsExp(workouts.id)),
          leftOuterJoin(workoutPhases,
              workoutPhases.workoutSessionId.equalsExp(workoutSessions.id)),
          leftOuterJoin(workoutItems,
              workoutItems.workoutPhaseId.equalsExp(workoutPhases.id)),
          leftOuterJoin(workoutSets,
              workoutSets.workoutItemId.equalsExp(workoutItems.id)),
          leftOuterJoin(
              exercises, exercises.id.equalsExp(workoutSets.exerciseId))
        ])
        .get()
        .then(_mapJoinedWorkouts)
        .then((value) => value.isNotEmpty ? value.single : null);
  }

  Future<JoinedWorkoutSessionM?> getJoinedSessionById(int id) {
    return (select(workoutSessions)..where((t) => t.id.equals(id)))
        .join([
          leftOuterJoin(workoutPhases,
              workoutPhases.workoutSessionId.equalsExp(workoutSessions.id)),
          leftOuterJoin(workoutItems,
              workoutItems.workoutPhaseId.equalsExp(workoutPhases.id)),
          leftOuterJoin(workoutSets,
              workoutSets.workoutItemId.equalsExp(workoutItems.id)),
          leftOuterJoin(
              exercises, exercises.id.equalsExp(workoutSets.exerciseId))
        ])
        .get()
        .then(_mapJoinedSessions)
        .then((value) => value.isNotEmpty ? value.single : null);
  }

  List<JoinedWorkoutM> _mapJoinedWorkouts(rows) {
    Map<int, JoinedWorkoutM> workoutsMap = {};
    Map<int, JoinedWorkoutSessionM> sessionsMap = {};
    Map<int, JoinedWorkoutPhaseM> phasesMap = {};
    Map<int, JoinedWorkoutItemM> itemsMap = {};

    for (final row in rows) {
      final workout = row.readTable(workouts);

      // TODO Fix this spaghetti
      if (!workoutsMap.containsKey(workout.id)) {
        workoutsMap[workout.id] = JoinedWorkoutM(
            workout: workout,
            sessions: List<JoinedWorkoutSessionM>.empty(growable: true));
      }

      _mapJoinSessionRows(
          row.readTableOrNull(workoutSessions),
          sessionsMap,
          row.readTableOrNull(workoutPhases),
          phasesMap,
          row.readTableOrNull(workoutItems),
          itemsMap,
          row.readTableOrNull(workoutSets),
          row.readTableOrNull(exercises),
          workoutsMap[workout.id]);
    }
    return workoutsMap.values.toList();
  }

  List<JoinedWorkoutSessionM> _mapJoinedSessions(rows) {
    Map<int, JoinedWorkoutSessionM> sessionsMap = {};
    Map<int, JoinedWorkoutPhaseM> phasesMap = {};
    Map<int, JoinedWorkoutItemM> itemsMap = {};

    for (final row in rows) {
      _mapJoinSessionRows(
          row.readTableOrNull(workoutSessions),
          sessionsMap,
          row.readTableOrNull(workoutPhases),
          phasesMap,
          row.readTableOrNull(workoutItems),
          itemsMap,
          row.readTableOrNull(workoutSets),
          row.readTableOrNull(exercises),
          null);
    }
    return sessionsMap.values.toList();
  }

  void _mapJoinSessionRows(
      session,
      Map<int, JoinedWorkoutSessionM> sessionsMap,
      phase,
      Map<int, JoinedWorkoutPhaseM> phasesMap,
      item,
      Map<int, JoinedWorkoutItemM> itemsMap,
      set,
      exercise,
      JoinedWorkoutM? parentWorkout) {
    if (session != null) {
      if (!sessionsMap.containsKey(session.id)) {
        final joinedSession = JoinedWorkoutSessionM(
            session: session,
            phases: List<JoinedWorkoutPhaseM>.empty(growable: true));
        sessionsMap[session.id] = joinedSession;
        if (parentWorkout != null) {
          parentWorkout.sessions.add(joinedSession);
        }
      }

      if (phase != null) {
        if (!phasesMap.containsKey(phase.id)) {
          final joinedPhase = JoinedWorkoutPhaseM(
              phase: phase,
              items: List<JoinedWorkoutItemM>.empty(growable: true));
          phasesMap[phase.id] = joinedPhase;
          sessionsMap[session.id]!.phases.add(joinedPhase);
        }

        if (item != null) {
          if (!itemsMap.containsKey(item.id)) {
            final joinedItem = JoinedWorkoutItemM(
                item: item,
                sets: List<JoinedWorkoutSetM>.empty(growable: true));
            itemsMap[item.id] = joinedItem;
            phasesMap[phase.id]!.items.add(joinedItem);
          }

          if (set != null && exercise != null) {
            itemsMap[item.id]!
                .sets
                .add(JoinedWorkoutSetM(set: set, exercise: exercise));
          }
        }
      }
    }
  }
}
