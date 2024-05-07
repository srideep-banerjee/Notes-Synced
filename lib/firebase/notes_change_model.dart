import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notes_flutter/firebase/firestore_note_model.dart';

class NotesChangeModel {
  final DocumentChangeType changeType;
  final FirestoreNoteModel? newData;
  final String? deletedId;

  NotesChangeModel(this.changeType, {required this.newData, required this.deletedId});
}