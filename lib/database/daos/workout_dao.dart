import 'package:training_app/database/database.dart';
import 'package:drift/drift.dart';
import 'package:training_app/database/join_entities.dart';

part 'workout_dao.g.dart';

@DriftAccessor(tables: [
  Workouts,
  WorkoutSessions,
  WorkoutPhases,
  WorkoutItems,
  WorkoutSets
])
class WorkoutDAO extends DatabaseAccessor<AppDatabase> with _$WorkoutDAOMixin {
  WorkoutDAO(AppDatabase db) : super(db);

  Future<WorkoutM?> getWorkoutById(int id) =>
      (select(workouts)..where((t) => t.id.equals(id))).getSingleOrNull();

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

  Future<List<JoinedWorkoutM>> getAllJoinedWorkouts() {
    return (select(workouts))
        .join([
          leftOuterJoin(workoutSessions,
              workoutSessions.workoutId.equalsExp(workouts.id)),
          leftOuterJoin(workoutPhases,
              workoutPhases.workoutSessionId.equalsExp(workoutSessions.id)),
          leftOuterJoin(workoutItems,
              workoutItems.workoutPhaseId.equalsExp(workoutPhases.id)),
          leftOuterJoin(
              workoutSets, workoutSets.workoutItemId.equalsExp(workoutItems.id))
        ])
        .get()
        .then((rows) {
          Map<int, JoinedWorkoutM> workoutsMap = {};
          Map<int, JoinedWorkoutSessionM> sessionsMap = {};
          Map<int, JoinedWorkoutPhaseM> phasesMap = {};
          Map<int, JoinedWorkoutItemM> itemsMap = {};

          for (final row in rows) {
            final workout = row.readTable(workouts);
            final session = row.readTableOrNull(workoutSessions);
            final phase = row.readTableOrNull(workoutPhases);
            final item = row.readTableOrNull(workoutItems);
            final set = row.readTableOrNull(workoutSets);

            // TODO Fix this spaghetti
            if (!workoutsMap.containsKey(workout.id)) {
              workoutsMap[workout.id] = JoinedWorkoutM(
                  workout: workout,
                  sessions: List<JoinedWorkoutSessionM>.empty(growable: true));
            }

            if (session != null) {
              if (!sessionsMap.containsKey(session.id)) {
                final joinedSession = JoinedWorkoutSessionM(
                    session: session,
                    phases: List<JoinedWorkoutPhaseM>.empty(growable: true));
                sessionsMap[session.id] = joinedSession;
                workoutsMap[workout.id]!.sessions.add(joinedSession);
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
                        sets: List<WorkoutSetM>.empty(growable: true));
                    itemsMap[item.id] = joinedItem;
                    phasesMap[phase.id]!.items.add(joinedItem);
                  }

                  if (set != null) {
                    itemsMap[item.id]!.sets.add(set);
                  }
                }
              }
            }
          }
          return workoutsMap.values.toList();
        });
  }
}
