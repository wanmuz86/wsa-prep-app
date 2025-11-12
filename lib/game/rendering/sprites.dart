import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class SpriteCache {
  static final SpriteCache _instance = SpriteCache._internal();
  factory SpriteCache() => _instance;
  SpriteCache._internal();

  ui.Image? _skierImage;
  ui.Image? _obstacleImage;
  ui.Image? _coinImage;
  ui.Image? _treeImage;

  Future<void> loadSprites() async {
    try {
      final skierData = await rootBundle.load('assets/images/skier.png');
      _skierImage = await _decodeImage(skierData.buffer.asUint8List());

      final obstacleData = await rootBundle.load('assets/images/obstacle.png');
      _obstacleImage = await _decodeImage(obstacleData.buffer.asUint8List());

      final coinData = await rootBundle.load('assets/images/coin.png');
      _coinImage = await _decodeImage(coinData.buffer.asUint8List());

      final treeData = await rootBundle.load('assets/images/game_bg_trees.png');
      _treeImage = await _decodeImage(treeData.buffer.asUint8List());
    } catch (e) {
      debugPrint('Error loading sprites: $e');
      // Create placeholder images if assets not found
      _skierImage = await _createPlaceholderImage(50, 80, Colors.blue);
      _obstacleImage = await _createPlaceholderImage(60, 60, Colors.red);
      _coinImage = await _createPlaceholderImage(60, 60, Colors.yellow);
      _treeImage = await _createPlaceholderImage(400, 800, Colors.green);
    }
  }

  Future<ui.Image> _decodeImage(Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  Future<ui.Image> _createPlaceholderImage(int width, int height, Color color) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()..color = color;
    canvas.drawRect(Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()), paint);
    final picture = recorder.endRecording();
    return await picture.toImage(width, height);
  }

  ui.Image? get skierImage => _skierImage;
  ui.Image? get obstacleImage => _obstacleImage;
  ui.Image? get coinImage => _coinImage;
  ui.Image? get treeImage => _treeImage;
}

