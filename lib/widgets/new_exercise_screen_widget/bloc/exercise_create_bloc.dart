import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:training_app/models/exercises_models.dart';

part 'exercise_create_event.dart';
part 'exercise_create_state.dart';

class ExerciseCreateBloc extends Bloc<ExerciseCreateEvent, ExerciseCreateState> {
  ExerciseCreateBloc() : super(ExerciseCreateInitial()) {
    on<ExerciseCreateEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
