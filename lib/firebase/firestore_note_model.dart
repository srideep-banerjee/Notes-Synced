class FirestoreNoteModel{
  final String documentId;
  final String title;
  final String content;
  final String lastUpdated;

  FirestoreNoteModel(this.documentId, this.title, this.content, this.lastUpdated);

  static FirestoreNoteModel fromMap(Map<String, Object?> map) {
    return FirestoreNoteModel(
      map["documentId"] as String,
      map["title"] as String,
      map["content"] as String,
      map["lastUpdated"] as String,
    );
  }

  Map<String, Object?> toMap() {
    return {
      "documentId": documentId,
      "title": title,
      "content": content,
      "lastUpdated": lastUpdated
    };
  }
}