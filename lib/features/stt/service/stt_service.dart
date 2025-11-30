import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

class STTService {
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _isInitialized = false;
  String _currentTranscript = '';
  Function(String)? _onTranscriptUpdate;

  Future<void> initialize() async {
    if (_isInitialized) return;

    final hasPermission = await Permission.speech.request();
    if (!hasPermission.isGranted) {
      throw Exception('Speech recognition permission not granted');
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
      throw Exception('Speech recognition not available');
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

