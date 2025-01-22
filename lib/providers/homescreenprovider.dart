// notes_provider.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotesProvider with ChangeNotifier {
  bool _isGridView = true;
  List<QueryDocumentSnapshot> _notes = [];
  bool _isLoading = false;

  bool get isGridView => _isGridView;
  List<QueryDocumentSnapshot> get notes => _notes;
  bool get isLoading => _isLoading;

  void toggleView() {
    _isGridView = !_isGridView;
    notifyListeners();
  }

  Future<void> addNote(String title, String content) async {
    try {
      final colorIndex = DateTime.now().microsecond % 6; // 6 is the number of colors
      await FirebaseFirestore.instance.collection('notes').add({
        'title': title,
        'content': content,
        'timestamp': FieldValue.serverTimestamp(),
        'colorIndex': colorIndex,
      });
      notifyListeners();
    } catch (e) {
      // Handle error
      print('Error adding note: $e');
    }
  }

  Future<void> updateNote(String id, String title, String content) async {
    try {
      await FirebaseFirestore.instance.collection('notes').doc(id).update({
        'title': title,
        'content': content,
        'lastModified': FieldValue.serverTimestamp(),
      });
      notifyListeners();
    } catch (e) {
      // Handle error
      print('Error updating note: $e');
    }
  }

  Future<void> deleteNote(String id) async {
    try {
      await FirebaseFirestore.instance.collection('notes').doc(id).delete();
      notifyListeners();
    } catch (e) {
      // Handle error
      print('Error deleting note: $e');
    }
  }

  Stream<QuerySnapshot> getNotesStream() {
    return FirebaseFirestore.instance
        .collection('notes')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}