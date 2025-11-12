import 'package:flutter/scheduler.dart';
import 'dart:async';

/// Game loop using Ticker for frame-based updates
class GameLoop {
  Ticker? _ticker;
  Function(double)? _onUpdate;
  bool _isPaused = false;
  int _lastFrameTime = 0;

  bool get isPaused => _isPaused;

  void start(Function(double) onUpdate) {
    _onUpdate = onUpdate;
    _isPaused = false;
    _lastFrameTime = DateTime.now().millisecondsSinceEpoch;

    _ticker = Ticker((elapsed) {
      if (!_isPaused && _onUpdate != null) {
        final currentTime = DateTime.now().millisecondsSinceEpoch;
        final deltaTime = (currentTime - _lastFrameTime) / 1000.0; // Convert to seconds
        _lastFrameTime = currentTime;
        _onUpdate!(deltaTime);
      }
    });

    _ticker?.start();
  }

  void pause() {
    _isPaused = true;
  }

  void resume() {
    _isPaused = false;
    _lastFrameTime = DateTime.now().millisecondsSinceEpoch;
  }

  void stop() {
    _ticker?.stop();
    _ticker?.dispose();
    _ticker = null;
    _isPaused = false;
  }

  void dispose() {
    stop();
  }
}

