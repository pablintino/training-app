import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'workout_global_editing_event.dart';
part 'workout_global_editing_state.dart';

class WorkoutGlobalEditingBloc extends Bloc<WorkoutGlobalEditingEvent, WorkoutGlobalEditingState> {
  WorkoutGlobalEditingBloc() : super(WorkoutGlobalEditingInitial()) {
    on<WorkoutGlobalEditingEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
