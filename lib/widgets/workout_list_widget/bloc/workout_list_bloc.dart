import 'dart:async';

import 'package:bloc/bloc.dart';
import "package:collection/collection.dart";
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';
import 'package:meta/meta.dart';
import 'package:training_app/models/workout_models.dart';
import 'package:training_app/repositories/workouts_repository.dart';
import 'package:training_app/utils/streams.dart';

part 'workout_list_event.dart';

part 'workout_list_state.dart';

class WorkoutListBloc extends Bloc<WorkoutListEvent, WorkoutListState> {
  final WorkoutRepository _workoutRepository;

  bool get isFetching => state is StartListLoadingState;

  WorkoutListBloc()
      : _workoutRepository = GetIt.instance<WorkoutRepository>(),
        super(WorkoutListLoadingState()) {
    on<WorkoutFetchEvent>((event, emit) => _handleFetchEvent(emit, event));
    on<ModifiedOrCreatedWorkoutEvent>(
        (event, emit) => _handleListModificationEvent(event, emit));
    on<SearchFilterUpdateFetchEvent>(
        (event, emit) => _handleFilterChangeEvent(event, emit),
        transformer:
            DebounceTransformer.debounce(const Duration(milliseconds: 500)));
  }

  Future<void> _handleFetchEvent(Emitter emit, WorkoutFetchEvent event) async {
    emit(StartListLoadingState.fromState(state));

    // On reload just grab the first page
    final pageNumber = !event.reload
        ? (state.workouts.length / WorkoutRepository.PAGE_SIZE).truncate()
        : 0;

    await _workoutRepository
        .getWorkoutsByPage(pageNumber, state.searchFilter)
        .then((retrievedWorkouts) {
      List<Workout> workouts = !event.reload
          ? (List.from(state.workouts)
            ..addAll(_removeExistingWorkouts(state, retrievedWorkouts)))
          : retrievedWorkouts;

      emit(WorkoutListLoadingState.fromState(state, workouts: workouts));
    }).catchError((err) {
      emit(WorkoutListErrorState.fromState(state, err.toString()));
    });
  }

  Future<void> _handleListModificationEvent(
      ModifiedOrCreatedWorkoutEvent event, Emitter emit) async {
    if (event.workout.id != null) {
      int index = state.workouts
          .indexWhere((element) => element.id == event.workout.id);
      List<Workout> workouts = List.from(state.workouts);
      if (index >= 0) {
        final oldName = workouts[index].name;
        workouts[index] = event.workout;
        // If name has changed we need to sort the list again
        if (oldName != event.workout.name) {
          workouts.sort(
              (a, b) => compareAsciiUpperCase(a.name ?? '', b.name ?? ''));
        }
        emit(WorkoutListItemModifiedState.fromState(
            state, index, ModificationType.update,
            workouts: workouts));
      } else {
        workouts.add(event.workout);
        // On client sort of the new list after appending
        workouts
            .sort((a, b) => compareAsciiUpperCase(a.name ?? '', b.name ?? ''));
        emit(WorkoutListItemModifiedState.fromState(
            state,
            workouts.indexWhere((element) => element.id == event.workout.id),
            ModificationType.creation,
            workouts: workouts));
      }
    }
  }

  Future<void> _handleFilterChangeEvent(
      SearchFilterUpdateFetchEvent event, Emitter emit) async {
    final filter = (event.filter ?? '').isEmpty ? null : event.filter;
    // Reset the whole state
    emit(WorkoutListLoadingState.fromState(state));

    await _workoutRepository
        .getWorkoutsByPage(0, filter)
        .then((retrievedWorkouts) {
      // Do not add old exercises from state.exercises
      emit(WorkoutListLoadingState.fromState(state,
          searchFilter: filter, workouts: retrievedWorkouts));
    }).catchError((err) {
      emit(WorkoutListErrorState.fromState(state, err.toString()));
    });
  }

  static List<Workout> _removeExistingWorkouts(
      WorkoutListState state, final List<Workout> list) {
    return list.where((element) => !state.workouts.contains(element)).toList();
  }
}
