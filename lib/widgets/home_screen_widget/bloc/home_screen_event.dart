part of 'home_screen_bloc.dart';

class BottomNavigationEvent extends Equatable {
  const BottomNavigationEvent(this._selectedItem);

  final BottomNavigationItem _selectedItem;

  @override
  List<Object> get props => [_selectedItem];
}
