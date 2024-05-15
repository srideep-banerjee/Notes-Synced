import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notes_flutter/default_settings.dart';
import 'package:notes_flutter/firebase/firebase_emulator.dart';
import 'package:notes_flutter/firebase/firestore_note_model.dart';
import 'package:notes_flutter/firebase/notes_change_model.dart';
import 'package:notes_flutter/firebase/user_document_model.dart';
import 'package:notes_flutter/models/notes_item.dart';

class FirestoreHelper {

  final Future<FirebaseFirestore> _futureFirebaseFirestore;

  FirestoreHelper(Future<FirebaseApp> futureFirebaseApp, [FirebaseEmulator? emulator]):
    _futureFirebaseFirestore = futureFirebaseApp.
    then((_) {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      firestore.settings = const Settings(
        persistenceEnabled: false
      );
      if(emulator != null) {
        firestore.useFirestoreEmulator(emulator.ip, emulator.port + 1);
      }
      return firestore;
    });

  Future<void> createUserDocument(String uid) async {
    FirebaseFirestore firestore = await _futureFirebaseFirestore;

    await firestore.doc("users/$uid").set(
      {"last_updated": FieldValue.serverTimestamp()},
      SetOptions(merge: true),
    );
  }

  Future<UserDocumentModel?> getUserDocument(String uid) async {
    FirebaseFirestore firestore = await _futureFirebaseFirestore;

    UserDocumentModel? from(
        DocumentSnapshot<Map<String, dynamic>> snapshot,
        SnapshotOptions? options
        ) {
      if (!snapshot.exists) return null;
      return UserDocumentModel.fromMap(snapshot.data()!);
    }

    Map<String, Object?> to(UserDocumentModel? userDocumentModel, SetOptions? options) {
      return userDocumentModel?.toMap() ?? <String, Object?>{};
    }

    return (
        await firestore
            .doc("users/$uid")
            .withConverter(fromFirestore: from, toFirestore: to)
            .get()
    ).data();
  }

  Future<List<String>> getNewDocumentIds(int count) async {
    FirebaseFirestore firestore = await _futureFirebaseFirestore;
    CollectionReference colRef = firestore.collection("users");
    List<String> newIds = [];
    for (int i = 0; i < count; i++) {
      newIds.add(colRef.doc().id);
    }
    return newIds;
  }

  Future<void> setNote(String uid, String firestoreId, NotesItem newData) async {
    FirebaseFirestore firestore = await _futureFirebaseFirestore;
    WriteBatch batch = firestore.batch();
    DocumentReference docRef = firestore.doc("users/$uid/notes/$firestoreId");
    Map<String, dynamic> data = newData.toMap();
    data["last_updated"] = FieldValue.serverTimestamp();
    batch.set(docRef, data);
    batch.set(
      firestore.doc("users/$uid"),
      {"last_updated": FieldValue.serverTimestamp()},
      SetOptions(merge: true),
    );
    await batch.commit();
  }

  Future<void> upsertAllNotes(String uid, List<FirestoreNoteModel> notes) async {
    FirebaseFirestore firestore = await _futureFirebaseFirestore;
    WriteBatch batch = firestore.batch();

    batch.set(
      firestore.doc("users/$uid"),
      {"last_updated": FieldValue.serverTimestamp()},
      SetOptions(merge: true),
    );
    for (FirestoreNoteModel note in notes) {
      var data = note.toMap();
      data["last_updated"] = FieldValue.serverTimestamp();
      batch.set(
        firestore.doc("users/$uid/notes/${note.documentId}"),
        data,
        SetOptions(merge: true),
      );
    }
    await batch.commit();
  }

  Future<List<FirestoreNoteModel>> getUpdatedNoteList(String lastUpdated, String uid) async {
    FirebaseFirestore firestore = await _futureFirebaseFirestore;
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await firestore
        .collection("users/$uid/notes/")
        .where(DefaultSettings.lastUpdatedKeyName, isGreaterThan: lastUpdated)
        .get();

    return querySnapshot.docs.map((value) {
      return FirestoreNoteModel.fromMap(value.data(), value.id);
    }).toList();
  }

  /// Gets a streams of notes changes after lastUpdated for the user uid
  Stream<List<NotesChangeModel>> getNoteQueryStream(String lastUpdated, String uid) async* {
    FirebaseFirestore firestore = await _futureFirebaseFirestore;

    FirestoreNoteModel? from(DocumentSnapshot<Map<String, dynamic>> snapshot, SnapshotOptions? options) {

      if (!snapshot.exists) return null;
      return FirestoreNoteModel.fromMap(snapshot.data()!, snapshot.id);
    }

    Map<String, Object?> to(FirestoreNoteModel? model, SetOptions? options) {

      return model?.toMap() ?? <String, Object?>{};
    }

    if (lastUpdated.isEmpty) lastUpdated = DateTime(2).toUtc().toString();

    yield* firestore.collection("users/$uid/notes")
        .withConverter(fromFirestore: from, toFirestore: to)
        .where(DefaultSettings.lastUpdatedKeyName, isGreaterThan: Timestamp.fromDate(DateTime.parse(lastUpdated)))
        .snapshots()
        .map(
            (querySnapshot) => querySnapshot
                .docChanges
                .map (_docChangeToNotesChangeModel)
                .toList()
    );
  }

  NotesChangeModel _docChangeToNotesChangeModel(DocumentChange<FirestoreNoteModel?> docChange) {
    DocumentSnapshot<FirestoreNoteModel?> doc = docChange.doc;
    var newDoc = docChange.doc.data();
    var deletedId = docChange.type == DocumentChangeType.removed? doc.id : null;
    return NotesChangeModel(
      docChange.type,
      newData: newDoc,
      deletedId: deletedId,
    );
  }
}