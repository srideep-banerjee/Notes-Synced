import 'package:notes_flutter/models/notes_item.dart';

class NoteModel {
  final int index;
  final String title;
  final String content;
  const NoteModel({required this.index, required this.title, required this.content});

  NotesItem toNotesItem() {
    return NotesItem(title: title, content: content);
  }

  Map<String, Object?> toMap() {
    return {
      "index" : index,
      "title" : title,
      "content" : content,
    };
  }
}