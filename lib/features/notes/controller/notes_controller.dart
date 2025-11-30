import 'package:flutter/foundation.dart';
import '../model/note.dart';
import '../service/notes_service.dart';

class NotesController extends ChangeNotifier {
  List<Note> _notes = [];
  List<Note> _filteredNotes = [];
  String _searchQuery = '';
  bool _isLoading = false;

  List<Note> get notes => _filteredNotes;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;

  int get totalNotesCount => NotesService.getTotalNotesCount();
  int get likedNotesCount => NotesService.getLikedNotesCount();

  Future<void> loadNotes() async {
    _isLoading = true;
    notifyListeners();

    _notes = NotesService.getAllNotes();
    _filteredNotes = _notes;
    _isLoading = false;
    notifyListeners();
  }

  void searchNotes(String query) {
    _searchQuery = query;
    if (query.isEmpty) {
      _filteredNotes = _notes;
    } else {
      _filteredNotes = NotesService.searchNotes(query);
    }
    notifyListeners();
  }

  Future<void> addNote(Note note) async {
    await NotesService.addNote(note);
    await loadNotes();
  }

  Future<void> deleteNote(int id) async {
    await NotesService.deleteNote(id);
    await loadNotes();
  }

  Future<void> toggleLike(int id) async {
    await NotesService.toggleLike(id);
    await loadNotes();
  }

  List<Note> getLikedNotes() {
    return NotesService.getLikedNotes();
  }
}

