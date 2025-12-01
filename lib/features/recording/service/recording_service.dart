import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class RecordingService {
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  String? _currentRecordingPath;

  bool get isRecording => _isRecording;
  String? get currentRecordingPath => _currentRecordingPath;

  Future<bool> requestPermissions() async {
    // Only request permissions on mobile platforms
    if (kIsWeb) {
      return true; // Web doesn't need explicit permission
    }
    
    if (Platform.isAndroid || Platform.isIOS) {
      final status = await Permission.microphone.request();
      return status.isGranted;
    }
    
    return true; // Desktop platforms don't need explicit permission
  }

  Future<String> startRecording() async {
    if (_isRecording) {
      throw Exception('Recording already in progress');
    }

    final hasPermission = await requestPermissions();
    if (!hasPermission) {
      throw Exception('Microphone permission not granted');
    }

    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    _currentRecordingPath = '${directory.path}/recording_$timestamp.m4a';

    try {
      await _audioRecorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: _currentRecordingPath!,
      );
    } catch (e) {
      _currentRecordingPath = null;
      throw Exception('Failed to start recording: $e');
    }

    _isRecording = true;
    return _currentRecordingPath!;
  }

  Future<String?> stopRecording() async {
    if (!_isRecording) {
      return null;
    }

    final path = await _audioRecorder.stop();
    _isRecording = false;
    _currentRecordingPath = null;
    return path;
  }

  Future<void> cancelRecording() async {
    if (_isRecording) {
      await _audioRecorder.stop();
      if (_currentRecordingPath != null && File(_currentRecordingPath!).existsSync()) {
        await File(_currentRecordingPath!).delete();
      }
      _isRecording = false;
      _currentRecordingPath = null;
    }
  }

  void dispose() {
    _audioRecorder.dispose();
  }
}

