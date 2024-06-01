import 'package:cloud_firestore/cloud_firestore.dart';

class UserDocumentModel {
  final String lastUpdated;
  final int deleteIndex;
  UserDocumentModel(this.lastUpdated, this.deleteIndex);

  static UserDocumentModel fromMap(Map<String, dynamic> map) {
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
    if (map["delete_index"] is Timestamp) {
      map["delete_index"] = (map["delete_index"] as Timestamp)
          .toDate()
          .toUtc()
          .toString();
    } else if (map["delete_index"] is DateTime) {
      map["delete_index"] = (map["delete_index"] as DateTime)
          .toUtc()
          .toString();
    }
    return UserDocumentModel(
      map["last_updated"] as String,
      map["delete_index"] as int,
    );
  }

  Map<String, dynamic> toMap() => {
    "last_updated": Timestamp.fromDate(DateTime.parse(lastUpdated)),
    "delete_index": deleteIndex,
  };

  static UserDocumentModel? from(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options
      ) {
    if (!snapshot.exists) return null;
    return UserDocumentModel.fromMap(snapshot.data()!);
  }

  static Map<String, Object?> to(
      UserDocumentModel? userDocumentModel,
      SetOptions? options
      ) {
    return userDocumentModel?.toMap() ?? <String, Object?>{};
  }
}