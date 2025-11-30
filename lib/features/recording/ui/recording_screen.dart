import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../../core/theme/app_theme.dart';
import '../controller/recording_controller.dart';
import '../../notes/controller/notes_controller.dart';
import '../../notes/model/note.dart';
import '../../notes/service/notes_service.dart';
import '../../home/ui/home_screen.dart';

class RecordingScreen extends StatefulWidget {
  const RecordingScreen({super.key});

  @override
  State<RecordingScreen> createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen> {
  Timer? _timer;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecordingController>().initialize();
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _duration = Duration(seconds: _duration.inSeconds + 1);
      });
      context.read<RecordingController>().updateDuration(_duration);
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return hours == '00' ? '$minutes:$seconds' : '$hours:$minutes:$seconds';
  }

  Future<void> _saveNote() async {
    final recordingController = context.read<RecordingController>();
    final notesController = context.read<NotesController>();

    if (recordingController.audioPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No recording to save')),
      );
      return;
    }

    final note = Note(
      id: NotesService.getNextId(),
      audioPath: recordingController.audioPath!,
      transcript: recordingController.transcript.isEmpty
          ? 'Recording saved'
          : recordingController.transcript,
      isLiked: false,
      createdAt: DateTime.now(),
    );

    await notesController.addNote(note);
    recordingController.reset();

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Note saved successfully')),
      );
    }
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Record Voice Note'),
      ),
      body: Consumer<RecordingController>(
        builder: (context, controller, child) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Mic Icon
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: controller.isRecording
                          ? AppTheme.error.withValues(alpha: 0.1)
                          : AppTheme.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.mic,
                      size: 64,
                      color: controller.isRecording
                          ? AppTheme.error
                          : AppTheme.primary,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Timer
                  Text(
                    _formatDuration(_duration),
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Status Text
                  if (controller.isProcessing)
                    const Text(
                      'Processing...',
                      style: TextStyle(fontSize: 16, color: AppTheme.info),
                    )
                  else if (controller.isRecording)
                    const Text(
                      'Recording...',
                      style: TextStyle(fontSize: 16, color: AppTheme.error),
                    )
                  else if (controller.transcript.isNotEmpty)
                    const Text(
                      'Recording complete',
                      style: TextStyle(fontSize: 16, color: AppTheme.success),
                    ),

                  const SizedBox(height: 32),

                  // Transcript Preview
                  if (controller.transcript.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Transcript:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            controller.transcript,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),

                  const Spacer(),

                  // Control Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (!controller.isRecording && controller.audioPath == null)
                        ElevatedButton.icon(
                          onPressed: () async {
                            try {
                              await controller.startRecording();
                              _duration = Duration.zero;
                              _startTimer();
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(e.toString())),
                                );
                              }
                            }
                          },
                          icon: const Icon(Icons.mic),
                          label: const Text('Start Recording'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                          ),
                        )
                      else if (controller.isRecording)
                        ElevatedButton.icon(
                          onPressed: () async {
                            _stopTimer();
                            try {
                              await controller.stopRecording();
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(e.toString())),
                                );
                              }
                            }
                          },
                          icon: const Icon(Icons.stop),
                          label: const Text('Stop Recording'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.error,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                          ),
                        )
                      else if (controller.audioPath != null)
                        Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                controller.reset();
                                _duration = Duration.zero;
                                setState(() {});
                              },
                              icon: const Icon(Icons.refresh),
                              label: const Text('Record Again'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.warning,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton.icon(
                              onPressed: _saveNote,
                              icon: const Icon(Icons.save),
                              label: const Text('Save Note'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.success,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

