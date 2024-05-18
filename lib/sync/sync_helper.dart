import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:notes_flutter/default_settings.dart';
import 'package:notes_flutter/firebase/auth.dart';
import 'package:notes_flutter/firebase/firebase_helper.dart';
import 'package:notes_flutter/firebase/firestore_helper.dart';
import 'package:notes_flutter/firebase/firestore_note_model.dart';
import 'package:notes_flutter/firebase/notes_change_model.dart';
import 'package:notes_flutter/firebase/user_document_model.dart';
import 'package:notes_flutter/local/database_local.dart';
import 'package:notes_flutter/local/note_model.dart';
import 'package:notes_flutter/local/preferences_helper.dart';
import 'package:notes_flutter/models/notes_item.dart';
import 'package:notes_flutter/sync/connectivity_helper.dart';
import 'package:notes_flutter/sync/sync_stream.dart';

class SyncHelper {

  User? user;

  InternetConnectionStatus connectionStatus = InternetConnectionStatus.disconnected;

  bool pendingSyncExportsExist = true;

  FirestoreHelper firestoreHelper;
  Authenticator authenticator;
  DatabaseHelper databaseHelper;
  PreferencesHelper preferencesHelper;

  late StreamSubscription<void> _syncStreamSubscription;

  SyncHelper(
      this.databaseHelper,
      FirebaseHelper firebaseHelper,
      this.preferencesHelper)
      : firestoreHelper = firebaseHelper.firestoreHelper,
        authenticator = firebaseHelper.authenticator {
    _syncStreamSubscription = _syncStream().listen((event) {});
  }

  Future<void> createUserDocIfNecessary() async {
    String uid = user!.uid;
    UserDocumentModel? userDoc = await firestoreHelper.getUserDocument(uid);
    if (userDoc == null) {
      await firestoreHelper.createUserDocument(uid);
    }
  }

  Stream<void> _syncStream() async* {
    String lastUpdated = await preferencesHelper
        .getString(DefaultSettings.lastUpdatedKeyName) ?? "";

    Stream<User?> userStream = authenticator.getUserStream();
    Stream<InternetConnectionStatus> connectionStream = ConnectivityHelper()
        .connectivityStream;

    Stream<List<NotesChangeModel>> noteChangeStream = SyncStream(
      userStream,
      connectionStream,
      (user) {
        print("User changed 1");
        return firestoreHelper.getNoteQueryStream(lastUpdated, user.uid);
      },
      (user) async {
        print("user changed 2");
        this.user = user;
        if (pendingSyncExportsExist && syncable) {
          await createUserDocIfNecessary();
          await exportPendingSyncs();
        }
      },
      (connectionStatus) async {
        print("Connection status: ${connectionStatus.name}");
        this.connectionStatus = connectionStatus;
        if (pendingSyncExportsExist && syncable) {
          await exportPendingSyncs();
        }
      }
    ).stream;

    await for(List<NotesChangeModel> noteChanges in noteChangeStream) {
      List<FirestoreNoteModel> firestoreNoteList = noteChanges
          .where((element) => element.changeType != DocumentChangeType.removed)
          .map((element) => element.newData!).toList();

      List<String> deletedFirestoreIdList = noteChanges
          .where((element) => element.changeType == DocumentChangeType.removed)
          .map((element) => element.deletedId!)
          .toList();

      await databaseHelper.upsertAndDeleteFirebaseNotes(firestoreNoteList, deletedFirestoreIdList);

      if (firestoreNoteList.isEmpty) continue;

      String lastUpdated = firestoreNoteList
          .reduce((fn1, fn2) => fn1.lastUpdated.compareTo(fn2.lastUpdated) == 1 ? fn1 : fn2)
          .lastUpdated;
      await preferencesHelper.setString(
        DefaultSettings.lastUpdatedKeyName,
        lastUpdated,
      );

      yield noteChanges;
    }
  }

  Future<void> exportPendingSyncs() async {
    String uid = user!.uid;
    String localLastUpdatedTime = await preferencesHelper
        .getString(DefaultSettings.lastUpdatedKeyName) ?? "";

    List<NoteModel> localUpserts = await databaseHelper
        .getLocalUpsertList(localLastUpdatedTime);

    await firestoreHelper.upsertAllNotes(
      uid,
      localUpserts
          .map((e) => e.toFirestoreNoteModel()!)
          .toList(),
    );
  }

  Future<void> addNewNote(NotesItem note) async {
    String uid = user?.uid ?? "";
    int index = await databaseHelper
        .addNote(note, _getCurrentTimestamp());
    String newFirestoreId = (await _generateAndUpdateFirestoreIdsLocally([index]))[0];
    if (syncable) {
      await firestoreHelper.setNote(uid, newFirestoreId, note);
    } else {
      pendingSyncExportsExist = true;
    }
  }

  Future<void> updateNote(NoteModel note) async {
    if (syncable) {

      if (note.firestoreId == null) {
        String newFirestoreId = (await _generateAndUpdateFirestoreIdsLocally([note.index]))[0];

        note = note.setFirestoreId(newFirestoreId);
      }
      await firestoreHelper.setNote(user!.uid, note.firestoreId!, note.toNotesItem());

    } else {
      await databaseHelper.updateNote(note);
      pendingSyncExportsExist = true;
    }
  }

  bool get syncable => user != null && connectionStatus == InternetConnectionStatus.connected;

  Future<List<String>> _generateAndUpdateFirestoreIdsLocally(List<int> databaseIndices) async {
    List<String> newIds = await firestoreHelper
        .getNewDocumentIds(databaseIndices.length);

    await databaseHelper.updateNewFirestoreIds(
      databaseIndices,
      newIds,
    );

    return newIds;
  }

  String _getCurrentTimestamp() => DateTime.timestamp().toString();

  Future<void> dispose() async {
    _syncStreamSubscription.cancel();
  }
}