import 'package:notes_flutter/local/note_model.dart';

class NotesItem {
  final String title;
  final String content;
  const NotesItem({required this.title, required this.content});

  NoteModel toNoteModel(int index) {
    return NoteModel(index: index, title: title, content: content);
  }

  Map<String, Object?> toMap() {
    return {
      "title" : title,
      "content" : content,
    };
  }
}