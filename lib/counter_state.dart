abstract class CounterState {
  final int value;
  const CounterState({required this.value});
}

class CounterStateValid extends CounterState {
  const CounterStateValid({required super.value});
}

class CounterStateInvalid extends CounterState {
  const CounterStateInvalid({required super.value});
}
