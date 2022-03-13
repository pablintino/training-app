part of 'home_screen_bloc.dart';

class BottomNavigationState extends Equatable {
  const BottomNavigationState(this.selectedItem);
  final BottomNavigationItem selectedItem;
  @override
  List<Object> get props => [selectedItem];
}
