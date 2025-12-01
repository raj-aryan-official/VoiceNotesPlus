import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_formatter.dart';
import '../../notes/controller/notes_controller.dart';
import '../../notes/model/note.dart';
import '../../notes/ui/note_detail_screen.dart';

class LikedNotesScreen extends StatelessWidget {
  const LikedNotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Liked Notes')),
      body: Consumer<NotesController>(
        builder: (context, controller, child) {
          final likedNotes = controller.getLikedNotes();

          if (likedNotes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No liked notes yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: likedNotes.length,
            itemBuilder: (context, index) {
              final note = likedNotes[index];
              return _LikedNoteCard(
                note: note,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => NoteDetailScreen(note: note),
                    ),
                  ).then((_) => controller.loadNotes());
                },
                onLike: () {
                  controller.toggleLike(note.id);
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _LikedNoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  final VoidCallback onLike;

  const _LikedNoteCard({
    required this.note,
    required this.onTap,
    required this.onLike,
  });

  @override
  Widget build(BuildContext context) {
    final firstLine = note.transcript.isEmpty
        ? 'No transcript'
        : note.transcript.split('\n').first;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      firstLine,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      DateFormatter.formatDateTime(note.createdAt),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.favorite, color: AppTheme.error),
                onPressed: onLike,
              ),
              IconButton(
                icon: const Icon(Icons.play_circle_outline),
                color: AppTheme.primary,
                onPressed: onTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
