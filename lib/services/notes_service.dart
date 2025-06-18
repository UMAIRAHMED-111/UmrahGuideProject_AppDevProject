import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/note.dart';

class NotesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SharedPreferences _prefs;
  static const String _localNotesKey = 'local_notes';

  NotesService(this._prefs);

  // Get all notes from Firestore
  Stream<List<Note>> getNotes(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notes')
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Note.fromFirestore(doc)).toList();
    });
  }

  // Get notes related to a specific ritual or site
  Stream<List<Note>> getRelatedNotes(String userId, {String? ritualId, String? siteId}) {
    Query query = _firestore
        .collection('users')
        .doc(userId)
        .collection('notes')
        .orderBy('updatedAt', descending: true);

    if (ritualId != null) {
      query = query.where('relatedRitualId', isEqualTo: ritualId);
    }
    if (siteId != null) {
      query = query.where('relatedSiteId', isEqualTo: siteId);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Note.fromFirestore(doc)).toList();
    });
  }

  // Add a new note
  Future<void> addNote(String userId, Note note) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('notes')
        .add(note.toFirestore());
    await _saveToLocalStorage(userId);
  }

  // Update a note
  Future<void> updateNote(String userId, Note note) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('notes')
        .doc(note.id)
        .update(note.toFirestore());
    await _saveToLocalStorage(userId);
  }

  // Delete a note
  Future<void> deleteNote(String userId, String noteId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('notes')
        .doc(noteId)
        .delete();
    await _saveToLocalStorage(userId);
  }

  // Save notes to local storage
  Future<void> _saveToLocalStorage(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('notes')
        .get();
    
    final notes = snapshot.docs
        .map((doc) => Note.fromFirestore(doc))
        .map((note) => note.toJson())
        .toList();
    
    await _prefs.setString(_localNotesKey, jsonEncode(notes));
  }

  // Get notes from local storage
  List<Note> getLocalNotes() {
    final String? jsonString = _prefs.getString(_localNotesKey);
    if (jsonString == null) return [];

    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((json) {
      final data = Map<String, dynamic>.from(json);
      return Note.fromJson(data);
    }).toList();
  }
} 