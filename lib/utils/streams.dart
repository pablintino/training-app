import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:rxdart/rxdart.dart';

abstract class DebounceTransformer {
  DebounceTransformer._();

  static EventTransformer<T> debounce<T>(Duration duration) {
    return (events, mapper) =>
        restartable<T>().call(events.debounceTime(duration), mapper);
  }
}
