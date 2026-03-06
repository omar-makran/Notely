import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynote/counter_event.dart';
import 'package:mynote/counter_state.dart';

class CounterBloc extends Bloc<CounterEvent, CounterState> {
  CounterBloc() : super(const CounterStateValid(value: 0)) {
    on<IncrementEvent>((event, emit) {
      final currentValue = state.value;
      final newValue = currentValue + 1;
      if (newValue < 0) {
        emit(CounterStateInvalid(value: newValue));
      } else {
        emit(CounterStateValid(value: newValue));
      }
    });

    on<DecrementEvent>((event, emit) {
      final currentValue = state.value;
      final newValue = currentValue - 1;
      if (newValue < 0) {
        emit(CounterStateInvalid(value: newValue));
      } else {
        emit(CounterStateValid(value: newValue));
      }
    });
  }
}
