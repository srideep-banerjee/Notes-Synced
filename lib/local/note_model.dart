import 'package:notes_flutter/models/notes_item.dart';

class NoteModel {
  final int index;
  final String title;
  final String content;
  final String time;
  const NoteModel({required this.index, required this.title, required this.content, required this.time});

  NotesItem toNotesItem() {
    return NotesItem(title: title, content: content);
  }

  Map<String, Object?> toMap() {
    return {
      "index" : index,
      "title" : title,
      "content" : content,
      "time" : time,
    };
  }
}