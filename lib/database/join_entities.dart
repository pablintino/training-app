import 'package:training_app/database/database.dart';

class JoinedWorkoutSetM {
  final WorkoutSetM set;
  final ExerciseM exercise;

  JoinedWorkoutSetM({required this.set, required this.exercise});
}

class JoinedWorkoutItemM {
  final WorkoutItemM item;
  final List<JoinedWorkoutSetM> sets;

  JoinedWorkoutItemM({required this.item, this.sets = const []});
}

class JoinedWorkoutPhaseM {
  final WorkoutPhaseM phase;
  final List<JoinedWorkoutItemM> items;

  JoinedWorkoutPhaseM({required this.phase, this.items = const []});
}

class JoinedWorkoutSessionM {
  final WorkoutSessionM session;
  final List<JoinedWorkoutPhaseM> phases;

  JoinedWorkoutSessionM({required this.session, this.phases = const []});
}

class JoinedWorkoutM {
  final WorkoutM workout;
  final List<JoinedWorkoutSessionM> sessions;

  JoinedWorkoutM({required this.workout, this.sessions = const []});
}
