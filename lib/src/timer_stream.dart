import 'dart:async';

class TimerStream {
  final Stream<int> _countdownStream;

  TimerStream({required int duration})
      : _countdownStream =
            Stream.periodic(Duration(seconds: 1), (_) => duration--)
                .take(duration + 1); // Include 0 for the final tick

  Stream<int> get stream => _countdownStream;
}
