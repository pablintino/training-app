import 'package:training_app/database/database.dart';

class JoinedWorkoutItemM {
  WorkoutItemM item;
  List<WorkoutSetM> sets;

  JoinedWorkoutItemM({required this.item, this.sets = const []});
}

class JoinedWorkoutPhaseM {
  WorkoutPhaseM phase;
  List<JoinedWorkoutItemM> items;

  JoinedWorkoutPhaseM({required this.phase, this.items = const []});
}

class JoinedWorkoutSessionM {
  WorkoutSessionM session;
  List<JoinedWorkoutPhaseM> phases;

  JoinedWorkoutSessionM({required this.session, this.phases = const []});
}

class JoinedWorkoutM {
  WorkoutM workout;
  List<JoinedWorkoutSessionM> sessions;

  JoinedWorkoutM({required this.workout, this.sessions = const []});
}
