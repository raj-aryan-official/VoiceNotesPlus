import 'package:hive_flutter/hive_flutter.dart';
import '../model/note.dart';
import '../../../core/constants/app_constants.dart';

class NotesService {
  static Box<Note>? _notesBox;

  static Future<void> init() async {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(NoteAdapter());
    }
    _notesBox = await Hive.openBox<Note>(AppConstants.notesBoxName);
  }

  static Box<Note> get notesBox {
    if (_notesBox == null) {
      throw Exception('NotesService not initialized. Call init() first.');
    }
    return _notesBox!;
  }

  static Future<void> addNote(Note note) async {
    await notesBox.put(note.id, note);
  }

  static Future<void> deleteNote(int id) async {
    await notesBox.delete(id);
  }

  static Future<void> toggleLike(int id) async {
    final note = notesBox.get(id);
    if (note != null) {
      note.isLiked = !note.isLiked;
      await note.save();
    }
  }

  static List<Note> getAllNotes() {
    return notesBox.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  static List<Note> getLikedNotes() {
    return notesBox.values
        .where((note) => note.isLiked)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  static List<Note> searchNotes(String query) {
    if (query.isEmpty) {
      return getAllNotes();
    }
    final lowerQuery = query.toLowerCase();
    return notesBox.values
        .where((note) =>
            note.transcript.toLowerCase().contains(lowerQuery))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  static int getTotalNotesCount() {
    return notesBox.length;
  }

  static int getLikedNotesCount() {
    return notesBox.values.where((note) => note.isLiked).length;
  }

  static int getNextId() {
    if (notesBox.isEmpty) {
      return 1;
    }
    return notesBox.values.map((note) => note.id).reduce((a, b) => a > b ? a : b) + 1;
  }
}

