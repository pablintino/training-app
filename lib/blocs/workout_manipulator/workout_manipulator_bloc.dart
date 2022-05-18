import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';
import 'package:training_app/models/workout_models.dart';
import 'package:training_app/repositories/workouts_repository.dart';

part 'workout_manipulator_event.dart';

part 'workout_manipulator_state.dart';

class WorkoutManipulatorBloc
    extends Bloc<WorkoutManipulatorEvent, WorkoutManipulatorState> {
  final WorkoutRepository _workoutRepository;

  WorkoutManipulatorBloc()
      : _workoutRepository = GetIt.instance<WorkoutRepository>(),
        super(WorkoutManipulatorInitialState()) {
    on<LoadWorkoutEvent>((event, emit) => _handleLoadWorkoutEvent(emit, event));
  }

  Future<void> _handleLoadWorkoutEvent(
      Emitter emit, LoadWorkoutEvent event) async {
    // On reload just grab the first page

    await _workoutRepository
        .getWorkout(event.workoutId, fat: true)
        .then((workout) {
      //TODO Check when workout is null
      emit(WorkoutManipulatorLoadedState(workout: workout!));
    }).catchError((err) {
      print("errrrrorrr");
    });
  }
}
