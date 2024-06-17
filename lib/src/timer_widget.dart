import 'package:flutter/material.dart';
import 'timer_stream.dart';

class TimerWidget extends StatelessWidget {
  final int duration;

  const TimerWidget({super.key, required this.duration});

  @override
  Widget build(BuildContext context) {
    final timerStream = TimerStream(duration: duration);

    return StreamBuilder<int>(
      stream: timerStream.stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (!snapshot.hasData) {
          return const Text('Timer not started');
        }

        final remainingSeconds = snapshot.data!;
        return Text(
          '$remainingSeconds',
          style: const TextStyle(
            fontSize: 45.0,
            color: Colors.red,
          ),
        );
      },
    );
  }
}
