import 'dart:async';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter/foundation.dart';

class GyroService {
  static final GyroService _instance = GyroService._internal();
  factory GyroService() => _instance;
  GyroService._internal();

  StreamSubscription<GyroscopeEvent>? _gyroSubscription;
  double _tiltX = 0.0; // -1.0 (left) to 1.0 (right)
  bool _isAvailable = false;
  
  // Low-pass filter for smoothing
  static const double _alpha = 0.8;
  double _filteredX = 0.0;

  double get tiltX => _tiltX;
  bool get isAvailable => _isAvailable;

  void startListening(Function(double) onTiltChanged) {
    try {
      _gyroSubscription = gyroscopeEventStream().listen(
        (GyroscopeEvent event) {
          _isAvailable = true;
          
          // Apply low-pass filter
          _filteredX = _alpha * _filteredX + (1 - _alpha) * event.x;
          
          // Map gyroscope X to tilt (-1.0 left, 0.0 center, 1.0 right)
          // Negative X (left tilt) should decrease slope angle
          _tiltX = _filteredX.clamp(-1.0, 1.0);
          
          onTiltChanged(_tiltX);
        },
        onError: (error) {
          debugPrint('Gyroscope error: $error');
          _isAvailable = false;
        },
      );
    } catch (e) {
      debugPrint('Gyroscope initialization error: $e');
      _isAvailable = false;
    }
  }

  void stopListening() {
    _gyroSubscription?.cancel();
    _gyroSubscription = null;
    _tiltX = 0.0;
    _filteredX = 0.0;
  }

  void dispose() {
    stopListening();
  }
}

