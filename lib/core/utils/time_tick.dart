import 'dart:async';

/// Utility for time-based tick counting
class TimeTick {
  Timer? _timer;
  int _seconds = 0;
  Function(int)? _onTick;

  int get seconds => _seconds;

  void start(Function(int) onTick) {
    _onTick = onTick;
    _seconds = 0;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _seconds++;
      _onTick?.call(_seconds);
    });
  }

  void pause() {
    _timer?.cancel();
  }

  void resume() {
    if (_onTick != null) {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _seconds++;
        _onTick?.call(_seconds);
      });
    }
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  void reset() {
    stop();
    _seconds = 0;
  }

  void dispose() {
    stop();
  }
}

