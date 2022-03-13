import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:training_app/widgets/home_screen_widget/home_screen_constants.dart';

part 'home_screen_event.dart';

part 'home_screen_state.dart';

class HomeScreenBloc
    extends Bloc<BottomNavigationEvent, BottomNavigationState> {
  HomeScreenBloc()
      : super(BottomNavigationState(BottomNavigationItem.CurrentSession)) {
    on<BottomNavigationEvent>((event, emit) {
      emit(BottomNavigationState(event._selectedItem));
    });
  }
}
