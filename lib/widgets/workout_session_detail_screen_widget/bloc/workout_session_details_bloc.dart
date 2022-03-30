import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';
import 'package:training_app/models/workout_models.dart';
import 'package:training_app/repositories/workouts_repository.dart';

part 'workout_session_details_event.dart';

part 'workout_session_details_state.dart';

class WorkoutSessionDetailsBloc
    extends Bloc<WorkoutSessionDetailsEvent, WorkoutSessionDetailsState> {
  final WorkoutRepository _workoutRepository;

  WorkoutSessionDetailsBloc()
      : _workoutRepository = GetIt.instance<WorkoutRepository>(),
        super(WorkoutSessionDetailsInitial()) {
    on<LoadSessionEvent>((event, emit) => _handleLoadSessionEvent(emit, event));
  }

  Future<void> _handleLoadSessionEvent(
      Emitter emit, LoadSessionEvent event) async {
    // On reload just grab the first page

    await _workoutRepository
        .getWorkoutSession(event.sessionId, fat: true)
        .then((session) {
      emit(SessionLoadedState(session));
    }).catchError((err) {
      print("errrrrorrr");
    });
  }
}
