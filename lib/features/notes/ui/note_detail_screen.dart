import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_formatter.dart';
import '../model/note.dart';
import '../controller/notes_controller.dart';

class NoteDetailScreen extends StatefulWidget {
  final Note note;

  const NoteDetailScreen({super.key, required this.note});

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        _isPlaying = state == PlayerState.playing;
      });
    });
    _audioPlayer.onDurationChanged.listen((duration) {
      setState(() {
        _duration = duration;
      });
    });
    _audioPlayer.onPositionChanged.listen((position) {
      setState(() {
        _position = position;
      });
    });
  }

  Future<void> _playAudio() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        if (_position == Duration.zero || _position == _duration) {
          await _audioPlayer.play(DeviceFileSource(widget.note.audioPath));
        } else {
          await _audioPlayer.resume();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error playing audio: $e')),
        );
      }
    }
  }

  Future<void> _deleteNote() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final notesController = context.read<NotesController>();
      await notesController.deleteNote(widget.note.id);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Note deleted')),
        );
      }
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final note = widget.note;
    final controller = context.watch<NotesController>();
    final currentNote = controller.notes.firstWhere(
      (n) => n.id == note.id,
      orElse: () => note,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Note Details'),
        actions: [
          IconButton(
            icon: Icon(
              currentNote.isLiked ? Icons.favorite : Icons.favorite_border,
              color: currentNote.isLiked ? AppTheme.error : null,
            ),
            onPressed: () {
              controller.toggleLike(currentNote.id);
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteNote,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date/Time
            Text(
              DateFormatter.formatFullDateTime(currentNote.createdAt),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),

            const SizedBox(height: 24),

            // Transcript
            const Text(
              'Transcript:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                currentNote.transcript.isEmpty
                    ? 'No transcript available'
                    : currentNote.transcript,
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),
            ),

            const SizedBox(height: 32),

            // Audio Player
            const Text(
              'Audio:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Progress Bar
                    if (_duration > Duration.zero)
                      Column(
                        children: [
                          Slider(
                            value: _position.inSeconds.toDouble(),
                            min: 0,
                            max: _duration.inSeconds.toDouble(),
                            onChanged: (value) async {
                              await _audioPlayer.seek(Duration(seconds: value.toInt()));
                            },
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_formatDuration(_position)),
                              Text(_formatDuration(_duration)),
                            ],
                          ),
                        ],
                      ),

                    const SizedBox(height: 16),

                    // Play Button
                    ElevatedButton.icon(
                      onPressed: _playAudio,
                      icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                      label: Text(_isPlaying ? 'Pause' : 'Play'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

