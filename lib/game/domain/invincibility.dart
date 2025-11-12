import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../data/models/game_config.dart';

/// Manages invincibility mode state and coin consumption
class InvincibilityManager {
  bool _isActive = false;
  Timer? _coinDrainTimer;
  Function(int)? onCoinConsumed;
  VoidCallback? onStateChanged;

  bool get isActive => _isActive;

  void activate() {
    if (_isActive) return;
    
    _isActive = true;
    onStateChanged?.call();

    // Consume 1 coin per second
    _coinDrainTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      onCoinConsumed?.call(GameConfig.invincibilityCoinCostPerSecond);
    });
  }

  void deactivate() {
    if (!_isActive) return;
    
    _isActive = false;
    _coinDrainTimer?.cancel();
    _coinDrainTimer = null;
    onStateChanged?.call();
  }

  void dispose() {
    deactivate();
  }
}

