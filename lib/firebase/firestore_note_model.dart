import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreNoteModel{
  final String documentId;
  final String title;
  final String content;
  final String lastUpdated;

  FirestoreNoteModel(this.documentId, this.title, this.content, this.lastUpdated);

  static FirestoreNoteModel fromMap(Map<String, Object?> map, String id) {
    if (map["last_updated"] is Timestamp) {
      map["last_updated"] = (map["last_updated"] as Timestamp)
          .toDate()
          .toUtc()
          .toString();
    } else if (map["last_updated"] is DateTime) {
      map["last_updated"] = (map["last_updated"] as DateTime)
          .toUtc()
          .toString();
    }
    return FirestoreNoteModel(
      id,
      map["title"] as String,
      map["content"] as String,
      map["last_updated"] as String,
    );
  }

  Map<String, Object> toMap() {
    return {
      "title": title,
      "content": content,
      "last_updated": Timestamp.fromDate(DateTime.parse(lastUpdated)),
    };
  }
}