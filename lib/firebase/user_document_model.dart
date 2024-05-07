import 'package:cloud_firestore/cloud_firestore.dart';

class UserDocumentModel {
  final String lastUpdated;
  UserDocumentModel(this.lastUpdated);

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
    return UserDocumentModel(
      map["last_updated"] as String,
    );
  }

  Map<String, dynamic> toMap() => {
    "last_updated": Timestamp.fromDate(DateTime.parse(lastUpdated)),
  };
}