import 'package:flutter/foundation.dart';
import '../service/recording_service.dart';
import '../../stt/service/stt_service.dart';

class RecordingController extends ChangeNotifier {
  final RecordingService _recordingService = RecordingService();
  final STTService _sttService = STTService();

  bool _isRecording = false;
  bool _isProcessing = false;
  String _transcript = '';
  String? _audioPath;
  Duration _recordingDuration = Duration.zero;

  bool get isRecording => _isRecording;
  bool get isProcessing => _isProcessing;
  String get transcript => _transcript;
  String? get audioPath => _audioPath;
  Duration get recordingDuration => _recordingDuration;

  Future<void> initialize() async {
    await _sttService.initialize();
  }

  Future<void> startRecording() async {
    try {
      // Start STT listening first
      await _sttService.startListening(
        onTranscriptUpdate: (transcript) {
          _transcript = transcript;
          notifyListeners();
        },
      );
      
      // Then start audio recording
      _audioPath = await _recordingService.startRecording();
      _isRecording = true;
      _transcript = '';
      _recordingDuration = Duration.zero;
      notifyListeners();
    } catch (e) {
      _sttService.cancelListening();
      throw Exception('Failed to start recording: $e');
    }
  }

  Future<void> stopRecording() async {
    if (!_isRecording) return;

    try {
      // Stop STT first to get final transcript
      final finalTranscript = _sttService.stopListening();
      if (finalTranscript.isNotEmpty) {
        _transcript = finalTranscript;
      }
      
      // Then stop audio recording
      final path = await _recordingService.stopRecording();
      _isRecording = false;
      _audioPath = path;
      notifyListeners();
    } catch (e) {
      _isRecording = false;
      _sttService.cancelListening();
      notifyListeners();
      throw Exception('Failed to stop recording: $e');
    }
  }

  void updateDuration(Duration duration) {
    _recordingDuration = duration;
    notifyListeners();
  }

  void reset() {
    _isRecording = false;
    _isProcessing = false;
    _transcript = '';
    _audioPath = null;
    _recordingDuration = Duration.zero;
    notifyListeners();
  }

  @override
  void dispose() {
    _recordingService.dispose();
    super.dispose();
  }
}

