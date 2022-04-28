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
    return (update(workouts)..where((t) => t.id.equals(id))).write(
      WorkoutsCompanion(
        name: companion.name,
        description: companion.description,
      ),
    );
  }

  Future<WorkoutSessionM?> getWorkoutSessionById(int id) =>
      (select(workoutSessions)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  Future insertWorkoutSession(
          WorkoutSessionsCompanion workoutSessionsCompanion) =>
      into(workoutSessions).insert(workoutSessionsCompanion);

  Future updateWorkoutSessionById(int id, WorkoutSessionsCompanion companion) {
    return (update(workoutSessions)..where((t) => t.id.equals(id))).write(
      WorkoutSessionsCompanion(
        week: companion.week,
        weekDay: companion.weekDay,
        workoutId: companion.workoutId,
      ),
    );
  }

  Future<WorkoutPhaseM?> getWorkoutPhaseById(int id) =>
      (select(workoutPhases)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future insertWorkoutPhase(WorkoutPhasesCompanion workoutPhasesCompanion) =>
      into(workoutPhases).insert(workoutPhasesCompanion);

  Future updateWorkoutPhaseById(int id, WorkoutPhasesCompanion companion) {
    return (update(workoutPhases)..where((t) => t.id.equals(id))).write(
      WorkoutPhasesCompanion(
        name: companion.name,
        sequence: companion.sequence,
        workoutSessionId: companion.workoutSessionId,
      ),
    );
  }

  Future<WorkoutItemM?> getWorkoutItemById(int id) =>
      (select(workoutItems)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future insertWorkoutItem(WorkoutItemsCompanion workoutItemsCompanion) =>
      into(workoutItems).insert(workoutItemsCompanion);

  Future updateWorkoutItemById(int id, WorkoutItemsCompanion companion) {
    return (update(workoutItems)..where((t) => t.id.equals(id))).write(
      WorkoutItemsCompanion(
        name: companion.name,
        sequence: companion.sequence,
        rounds: companion.rounds,
        restTimeSecs: companion.restTimeSecs,
        timeCapSecs: companion.timeCapSecs,
        workModality: companion.workModality,
        workTimeSecs: companion.workTimeSecs,
        workoutPhaseId: companion.workoutPhaseId,
      ),
    );
  }

  Future<WorkoutSetM?> getWorkoutSetById(int id) =>
      (select(workoutSets)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future insertWorkoutSet(WorkoutSetsCompanion workoutSetsCompanion) =>
      into(workoutSets).insert(workoutSetsCompanion);

  Future updateWorkoutSetById(int id, WorkoutSetsCompanion companion) {
    return (update(workoutSets)..where((t) => t.id.equals(id))).write(
      WorkoutSetsCompanion(
          sequence: companion.sequence,
          weight: companion.weight,
          distance: companion.distance,
          setExecutions: companion.setExecutions,
          reps: companion.reps,
          workoutItemId: companion.workoutItemId,
          exerciseId: companion.exerciseId),
    );
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
              workoutsMap[workout.id] = JoinedWorkoutM(workout: workout);
            }

            if (session != null) {
              if (!sessionsMap.containsKey(session.id)) {
                final joinedSession = JoinedWorkoutSessionM(session: session);
                sessionsMap[session.id] = joinedSession;
                workoutsMap[workout.id]!.sessions.add(joinedSession);
              }

              if (phase != null) {
                if (!phasesMap.containsKey(phase.id)) {
                  final joinedPhase = JoinedWorkoutPhaseM(phase: phase);
                  phasesMap[phase.id] = joinedPhase;
                  sessionsMap[session.id]!.phases.add(joinedPhase);
                }

                if (item != null) {
                  if (!itemsMap.containsKey(item.id)) {
                    final joinedItem = JoinedWorkoutItemM(item: item);
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
          print(rows);
          return workoutsMap.values.toList();
        });
  }
}
