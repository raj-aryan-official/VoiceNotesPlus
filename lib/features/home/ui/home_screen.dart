import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/constants/app_constants.dart';
import '../../notes/controller/notes_controller.dart';
import '../../notes/model/note.dart';
import '../../recording/ui/recording_screen.dart';
import '../../notes/ui/note_detail_screen.dart';
import '../../liked/ui/liked_notes_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotesController>().loadNotes();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.neutral,
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        automaticallyImplyLeading: false,
      ),
      body: Consumer<NotesController>(
        builder: (context, controller, child) {
          return Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search notes...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              controller.searchNotes('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) {
                    controller.searchNotes(value);
                  },
                ),
              ),

              // Stats Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Total Notes',
                        count: controller.totalNotesCount,
                        icon: Icons.note,
                        color: AppTheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LikedNotesScreen(),
                            ),
                          );
                        },
                        child: _StatCard(
                          title: 'Liked Notes',
                          count: controller.likedNotesCount,
                          icon: Icons.favorite,
                          color: AppTheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Notes List
              Expanded(
                child: controller.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : controller.notes.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.mic_none,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No notes yet',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Tap the mic button to start recording',
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () => controller.loadNotes(),
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: controller.notes.length,
                              itemBuilder: (context, index) {
                                final note = controller.notes[index];
                                return _NoteCard(
                                  note: note,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => NoteDetailScreen(
                                          note: note,
                                        ),
                                      ),
                                    ).then((_) => controller.loadNotes());
                                  },
                                  onLike: () {
                                    controller.toggleLike(note.id);
                                  },
                                );
                              },
                            ),
                          ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const RecordingScreen(),
            ),
          );
          if (mounted) {
            context.read<NotesController>().loadNotes();
          }
        },
        icon: const Icon(Icons.mic),
        label: const Text('Record'),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    count.toString(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  final VoidCallback onLike;

  const _NoteCard({
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
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(
                  note.isLiked ? Icons.favorite : Icons.favorite_border,
                  color: note.isLiked ? AppTheme.error : Colors.grey,
                ),
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

