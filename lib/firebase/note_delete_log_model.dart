import 'package:cloud_firestore/cloud_firestore.dart';

class NoteDeleteLogModel {
  final String documentId;
  final String lastDeleted;

  NoteDeleteLogModel(this.documentId, this.lastDeleted);

  static NoteDeleteLogModel fromMap(Map<String, dynamic> map) {
    if (map["last_deleted"] is Timestamp) {
      map["last_deleted"] = (map["last_deleted"] as Timestamp)
          .toDate()
          .toUtc()
          .toString();
    } else if (map["last_deleted"] is DateTime) {
      map["last_deleted"] = (map["last_deleted"] as DateTime)
          .toUtc()
          .toString();
    }

    return NoteDeleteLogModel(
      map["document_id"] as String,
      map["last_deleted"] as String,
    );
  }

  Map<String, dynamic> toMap() => {
    "document_id": documentId,
    "last_deleted": Timestamp.fromDate(DateTime.parse(lastDeleted)),
  };

  static NoteDeleteLogModel? from(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options
      ) {
    if (!snapshot.exists) return null;
    return NoteDeleteLogModel.fromMap(snapshot.data()!);
  }

  static Map<String, Object?> to(
      NoteDeleteLogModel? noteDeleteLogModel,
      SetOptions? options
      ) {
    return noteDeleteLogModel?.toMap() ?? <String, Object?>{};
  }
}