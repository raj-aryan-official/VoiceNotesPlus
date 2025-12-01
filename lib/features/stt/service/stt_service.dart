import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'dart:io' show Platform;

class STTService {
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _isInitialized = false;
  String _currentTranscript = '';
  Function(String)? _onTranscriptUpdate;

  Future<void> initialize() async {
    if (_isInitialized) return;

    // Only request permissions on mobile platforms
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      final hasPermission = await Permission.speech.request();
      if (!hasPermission.isGranted) {
        debugPrint('Speech recognition permission not granted');
        return;
      }
    }

    final available = await _speechToText.initialize(
      onError: (error) {
        debugPrint('STT Error: $error');
      },
      onStatus: (status) {
        debugPrint('STT Status: $status');
      },
    );

    if (!available) {
      debugPrint('Speech recognition not available');
    }

    _isInitialized = true;
  }

  Future<String> startListening({
    Function(String)? onTranscriptUpdate,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    _onTranscriptUpdate = onTranscriptUpdate;
    _currentTranscript = '';

    await _speechToText.listen(
      onResult: (result) {
        _currentTranscript = result.recognizedWords;
        if (_onTranscriptUpdate != null) {
          _onTranscriptUpdate!(_currentTranscript);
        }
        if (result.finalResult) {
          // Don't stop automatically, let the controller handle it
        }
      },
      listenFor: const Duration(minutes: 5),
      pauseFor: const Duration(seconds: 3),
    );

    return _currentTranscript;
  }

  String stopListening() {
    _speechToText.stop();
    final transcript = _currentTranscript;
    _currentTranscript = '';
    _onTranscriptUpdate = null;
    return transcript;
  }

  void cancelListening() {
    _speechToText.cancel();
    _currentTranscript = '';
    _onTranscriptUpdate = null;
  }

  bool get isListening => _speechToText.isListening;
  String get currentTranscript => _currentTranscript;
}

