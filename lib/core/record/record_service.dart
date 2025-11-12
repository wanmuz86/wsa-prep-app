import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

/// Abstraction for screen recording with graceful fallback
class RecordService {
  static final RecordService _instance = RecordService._internal();
  factory RecordService() => _instance;
  RecordService._internal();

  bool _isRecording = false;
  String? _recordingStatus;
  List<Uint8List> _frameBuffer = [];
  Timer? _captureTimer;
  int _frameCount = 0;
  static const int _targetFps = 20;
  static const Duration _frameInterval = Duration(milliseconds: 1000 ~/ _targetFps);

  bool get isRecording => _isRecording;
  String? get recordingStatus => _recordingStatus;

  /// Start recording by capturing frames from a RepaintBoundary
  Future<bool> startRecording(GlobalKey repaintKey) async {
    if (_isRecording) return true;

    try {
      // Request permission if needed
      if (Platform.isAndroid || Platform.isIOS) {
        final status = await Permission.photos.status;
        if (!status.isGranted) {
          final result = await Permission.photos.request();
          if (!result.isGranted) {
            _recordingStatus = 'REC OFF';
            return false;
          }
        }
      }

      _isRecording = true;
      _frameBuffer.clear();
      _frameCount = 0;
      _recordingStatus = 'REC';

      // Start capturing frames
      _captureTimer = Timer.periodic(_frameInterval, (timer) {
        _captureFrame(repaintKey);
      });

      return true;
    } catch (e) {
      debugPrint('Recording start error: $e');
      _recordingStatus = 'REC OFF';
      _isRecording = false;
      return false;
    }
  }

  void _captureFrame(GlobalKey repaintKey) {
    try {
      final boundary = repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;

      boundary.toImage().then((image) {
        image.toByteData(format: ui.ImageByteFormat.png).then((byteData) {
          if (byteData != null) {
            _frameBuffer.add(byteData.buffer.asUint8List());
            _frameCount++;
          }
        });
      });
    } catch (e) {
      debugPrint('Frame capture error: $e');
    }
  }

  /// Stop recording and export to gallery
  Future<String?> stopRecording() async {
    if (!_isRecording) return null;

    _isRecording = false;
    _captureTimer?.cancel();
    _captureTimer = null;

    if (_frameBuffer.isEmpty) {
      _recordingStatus = 'REC OFF';
      return null;
    }

    try {
      // Export frames as PNG sequence to gallery
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final exportDir = Directory('${directory.path}/go_skiing_recording_$timestamp');
      await exportDir.create(recursive: true);

      // Save all frames
      for (int i = 0; i < _frameBuffer.length; i++) {
        final file = File('${exportDir.path}/frame_${i.toString().padLeft(5, '0')}.png');
        await file.writeAsBytes(_frameBuffer[i]);
      }

      _frameBuffer.clear();
      _recordingStatus = 'REC OFF';

      // Note: Actual export to system gallery requires platform channels
      // This is a best-effort implementation that saves to app documents
      debugPrint('Recording saved to: ${exportDir.path}');
      return exportDir.path;
    } catch (e) {
      debugPrint('Recording export error: $e');
      _recordingStatus = 'REC OFF';
      return null;
    }
  }
}

