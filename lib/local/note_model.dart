import 'package:notes_flutter/firebase/firestore_note_model.dart';
import 'package:notes_flutter/models/notes_item.dart';

class NoteModel {
  final int index;
  final String title;
  final String content;
  final String time;
  final String? firestoreId;
  const NoteModel({required this.index, required this.title, required this.content, required this.time, this.firestoreId});

  static NoteModel fromMap(Map<String, Object?> map) {
    return NoteModel(
      index: map["index"] as int,
      title: map["title"] as String,
      content: map["content"] as String,
      time: map["time"] as String,
      firestoreId: map["firestoreId"] as String?
    );
  }

  NotesItem toNotesItem() {
    return NotesItem(title: title, content: content);
  }

  Map<String, Object?> toMap() {
    return {
      "index" : index,
      "title" : title,
      "content" : content,
      "time" : time,
      "firestoreId" : firestoreId
    };
  }

  FirestoreNoteModel? toFirestoreNoteModel() {
    if (firestoreId == null) {
      return null;
    } else {
      return FirestoreNoteModel(firestoreId!, title, content, time);
    }
  }

  NoteModel setFirestoreId(String firestoreId) {
    return NoteModel(index: index, title: title, content: content, time: time, firestoreId: firestoreId);
  }
}