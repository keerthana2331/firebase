import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  static const List<Color> noteColors = [
    Color(0xFFffab91), // Peach
    Color(0xFFfff59d), // Light Yellow
    Color(0xFFb2dfdb), // Mint
    Color(0xFFe1bee7), // Light Purple
    Color(0xFFbbdefb), // Light Blue
    Color(0xFFf8bbd0), // Pink
  ];

  Future<void> _saveViewPreference(bool isGrid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isGridView', isGrid);
  }

  Future<bool> _getViewPreference() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isGridView') ?? true;
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) =>LogIn()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Error signing out. Please try again.'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(10),
        ),
      );
    }
  }

  Future<void> _addOrUpdateNote(BuildContext context, {String? id, String? currentTitle, String? currentContent}) async {
    String? title = currentTitle;
    String? content = currentContent;
    final titleController = TextEditingController(text: currentTitle);
    final contentController = TextEditingController(text: currentContent);
    final colorIndex = DateTime.now().microsecond % noteColors.length;

    await showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: noteColors[colorIndex].withOpacity(0.3),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                id == null ? 'New Note' : 'Edit Note',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 20),
              Material(
                elevation: 2,
                borderRadius: BorderRadius.circular(15),
                child: TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    hintText: 'Title',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(15),
                  ),
                  onChanged: (value) => title = value,
                ),
              ),
              const SizedBox(height: 15),
              Material(
                elevation: 2,
                borderRadius: BorderRadius.circular(15),
                child: TextField(
                  controller: contentController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: 'Write your note here...',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(15),
                  ),
                  onChanged: (value) => content = value,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () async {
                      if (title?.isNotEmpty == true && content?.isNotEmpty == true) {
                        final firestore = FirebaseFirestore.instance;
                        if (id == null) {
                          await firestore.collection('notes').add({
                            'title': title,
                            'content': content,
                            'timestamp': FieldValue.serverTimestamp(),
                            'colorIndex': colorIndex,
                          });
                        } else {
                          await firestore.collection('notes').doc(id).update({
                            'title': title,
                            'content': content,
                            'lastModified': FieldValue.serverTimestamp(),
                          });
                        }
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(id == null ? 'Add Note' : 'Save Changes'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  elevation: 2,
  backgroundColor: Colors.white,
  title: const Text(
    "My Sticky Notes",
    style: TextStyle(
      color: Colors.black87,
      fontWeight: FontWeight.bold,
    ),
  ),
  centerTitle: true,
  automaticallyImplyLeading: false, // This removes the back arrow
  actions: [
    IconButton(
      icon: const Icon(Icons.logout, color: Colors.black87),
      onPressed: () => _signOut(context),
      tooltip: 'Logout',
    ),
  ],
),

      body: FutureBuilder<bool>(
        future: _getViewPreference(),
        builder: (context, snapshot) {
          final isGrid = snapshot.data ?? true;
          
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('notes')
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.note_add_rounded,
                        size: 80,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No Notes Yet',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap + to create your first note',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                );
              }

              final notes = snapshot.data!.docs;

              if (isGrid) {
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    final noteData = note.data() as Map<String, dynamic>;
                    final colorIndex = noteData['colorIndex'] ?? index % noteColors.length;
                    
                    return _buildNoteCard(context, note.id, noteData, noteColors[colorIndex]);
                  },
                );
              } else {
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    final noteData = note.data() as Map<String, dynamic>;
                    final colorIndex = noteData['colorIndex'] ?? index % noteColors.length;
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildNoteCard(context, note.id, noteData, noteColors[colorIndex]),
                    );
                  },
                );
              }
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrUpdateNote(context),
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add),
        elevation: 4,
      ),
    );
  }

  Widget _buildNoteCard(BuildContext context, String id, Map<String, dynamic> noteData, Color color) {
    final timestamp = noteData['timestamp'] as Timestamp?;
    final dateStr = timestamp != null
        ? DateFormat('MMM d, y').format(timestamp.toDate())
        : 'No date';

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: color.withOpacity(0.7),
      child: InkWell(
        onTap: () => _addOrUpdateNote(
          context,
          id: id,
          currentTitle: noteData['title'],
          currentContent: noteData['content'],
        ),
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      noteData['title'] ?? 'Untitled',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Color(0xFF2C3E50),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  PopupMenuButton(
                    icon: const Icon(Icons.more_vert, color: Color(0xFF2C3E50)),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete),
                            SizedBox(width: 8),
                            Text('Delete'),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'edit') {
                        _addOrUpdateNote(
                          context,
                          id: id,
                          currentTitle: noteData['title'],
                          currentContent: noteData['content'],
                        );
                      } else if (value == 'delete') {
                        _deleteNoteConfirm(context, id);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Text(
                  noteData['content'] ?? 'No content',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[800],
                  ),
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                dateStr,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteNoteConfirm(BuildContext context, String id) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance.collection('notes').doc(id).delete();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Note deleted'),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }
}