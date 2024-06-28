import 'dart:async';
import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:notes_flutter/default_settings.dart';
import 'package:notes_flutter/firebase/auth.dart';
import 'package:notes_flutter/firebase/firebase_helper.dart';
import 'package:notes_flutter/firebase/firestore_helper.dart';
import 'package:notes_flutter/firebase/firestore_note_model.dart';
import 'package:notes_flutter/firebase/note_delete_log_model.dart';
import 'package:notes_flutter/firebase/notes_change_model.dart';
import 'package:notes_flutter/firebase/user_document_model.dart';
import 'package:notes_flutter/local/database_local.dart';
import 'package:notes_flutter/local/note_model.dart';
import 'package:notes_flutter/local/preferences_helper.dart';
import 'package:notes_flutter/models/notes_item.dart';
import 'package:notes_flutter/sync/connectivity_helper.dart';
import 'package:notes_flutter/sync/sync_stream.dart';
import 'package:notes_flutter/util/async/multiuse_streams.dart';

class SyncHelper {

  User? user;

  InternetConnectionStatus connectionStatus = InternetConnectionStatus.disconnected;

  bool pendingSyncExportsExist = true;

  FirestoreHelper firestoreHelper;
  Authenticator authenticator;
  DatabaseHelper databaseHelper;
  PreferencesHelper preferencesHelper;

  late MultiUseStream<InternetConnectionStatus> _connectionStream;

  late StreamSubscription<void> _syncStreamSubscription;
  late StreamSubscription<void> _deleteLogStreamSubscription;

  SyncHelper(
      this.databaseHelper,
      FirebaseHelper firebaseHelper,
      this.preferencesHelper)
      : firestoreHelper = firebaseHelper.firestoreHelper,
        authenticator = firebaseHelper.authenticator {

    _connectionStream = MultiUseStream(ConnectivityHelper().connectivityStream);

    _syncStreamSubscription = _syncStream().listen((event) {});
    _deleteLogStreamSubscription = _deleteLogStream().listen((event) {});
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
    Stream<InternetConnectionStatus> connectionStream = _connectionStream.stream();

    Stream<List<NotesChangeModel>> noteChangeStream = SyncStream<List<NotesChangeModel>>(
      userStream,
      connectionStream,
      (user) {
        if (kDebugMode) {
          print("User changed 1");
        }
        return firestoreHelper.getNoteQueryStream(lastUpdated, user.uid);
      },
      _onUserChange,
      _onConnectionChange,
    ).stream;

    await for(List<NotesChangeModel> noteChanges in noteChangeStream) {
      if (kDebugMode) {
        print("NOTE CHANGE EVENT : length = ${noteChanges.length}");
      }
      List<FirestoreNoteModel> firestoreNoteList = noteChanges
          .where((element) => element.changeType != DocumentChangeType.removed)
          .map((element) => element.newData!).toList();

      await databaseHelper.upsertFirebaseNotes(firestoreNoteList);

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
  
  Stream<List<NoteDeleteLogModel>> _deleteLogStream() async* {
    String lastDeleted = await preferencesHelper.getString(DefaultSettings.lastDeletedKeyName) ?? "";

    Stream<User?> userStream = authenticator.getUserStream();
    Stream<InternetConnectionStatus> connectionStream = _connectionStream.stream();

    Stream<List<NoteDeleteLogModel>> deleteLogStream = SyncStream<List<NoteDeleteLogModel>>(
      userStream,
      connectionStream,
      (user) => firestoreHelper.getDeletedIds(user.uid, lastDeleted),
      _onUserChange,
      _onConnectionChange,

    ).stream;

    await for(List<NoteDeleteLogModel> deleteLogs in deleteLogStream) {
      if (kDebugMode) {
        print("DELETE LOG EVENT : ${deleteLogs.map((e) => e.documentId).toList()}");
      }
      if (deleteLogs.isEmpty) continue;

      Set<String> deletedIds = deleteLogs.map((e) => e.documentId).toSet();
      await databaseHelper.deleteByFirestoreIds(deletedIds);

      lastDeleted = deleteLogs
          .reduce((fn1, fn2) => fn1.lastDeleted.compareTo(fn2.lastDeleted) == 1 ? fn1 : fn2)
          .lastDeleted;
      await preferencesHelper.setString(
        DefaultSettings.lastDeletedKeyName,
        lastDeleted,
      );

      yield deleteLogs;
    }
  }

  Future<void> _onUserChange(User? user) async {
    if (this.user?.uid == user?.uid) return;
    if (kDebugMode) {
      print("USER CHANGED");
      print(user?.uid);
    }
    bool shouldClearDelete = this.user != null;
    this.user = user;
    if (shouldClearDelete) {
      await databaseHelper.clearPendingDelete();
    }
    if (pendingSyncExportsExist && syncable) {
      await createUserDocIfNecessary();
      await exportPendingSyncs();
    }
  }

  Future<void> _onConnectionChange(InternetConnectionStatus connectionStatus) async {
    if (this.connectionStatus == connectionStatus) return;
    this.connectionStatus = connectionStatus;
    if (pendingSyncExportsExist && syncable) {
      await exportPendingSyncs();
    }
  }

  Future<void> exportPendingSyncs() async {
    if (kDebugMode) {
      print("EXPORTING PENDING SYNCS");
    }
    String uid = user!.uid;

    List<String> pendingDeleteIds = await databaseHelper.pendingDeleteIds();
    await firestoreHelper.deleteAllNotes(uid, pendingDeleteIds);
    await databaseHelper.clearPendingDelete();

    String localLastUpdatedTime = await preferencesHelper
        .getString(DefaultSettings.lastUpdatedKeyName) ?? "";

    List<NoteModel> localUpserts = await databaseHelper
        .getLocalUpsertList(localLastUpdatedTime);

    List<int> localUnsyncedIndices = localUpserts
        .where((note) => note.firestoreId == null)
        .map((note) => note.index)
        .toList(growable: false);

    List<String> newFirestoreIds = await _generateAndUpdateFirestoreIdsLocally(localUnsyncedIndices);

    int newIdIndex = 0;
    for (int i = 0; i < localUpserts.length; i++) {
      if (localUpserts[i].firestoreId == null) {
        localUpserts[i] = localUpserts[i].setFirestoreId(newFirestoreIds[newIdIndex++]);
      }
    }

    await firestoreHelper.upsertAllNotes(
      uid,
      localUpserts
          .map((e) => e.toFirestoreNoteModel()!)
          .toList(),
    );

    pendingSyncExportsExist = false;
  }

  ///Sometimes FirestoreId might be non-null in local database even if
  ///note is absent in firestore, but only in rare conditions
  Future<void> addNewNote(NotesItem note) async {
    String uid = user?.uid ?? "";
    int index = await databaseHelper
        .addNote(note, _getCurrentTimestamp());
    if (syncable) {
      String newFirestoreId = (await _generateAndUpdateFirestoreIdsLocally([index]))[0];
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
      pendingSyncExportsExist = true;
    }
    await databaseHelper.updateNote(note);
  }

  Future<void> deleteNote(NoteModel note) async {
    await deleteMultipleNotes([note]);
  }

  /// Assumes all notes are already present in local database
  Future<void> deleteMultipleNotes(List<NoteModel> notes) async {
    if (notes.isEmpty) return;

    List<String> firestoreIds = notes
        .where((element) => element.firestoreId != null)
        .map((e) => e.firestoreId!)
        .toList(growable: false);

    await databaseHelper.deleteMultipleNotes(notes, addToPending: true);

    if (syncable) {
      await firestoreHelper.deleteAllNotes(user!.uid, firestoreIds);
      await databaseHelper.clearPendingDelete();
    } else {
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
    await _syncStreamSubscription.cancel();
    await _deleteLogStreamSubscription.cancel();
  }
}