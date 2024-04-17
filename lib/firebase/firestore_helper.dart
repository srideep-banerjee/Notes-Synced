import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notes_flutter/firebase/firebase_emulator.dart';

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

  Stream<String?> getLastUpdatedStream(String uid) async* {
    FirebaseFirestore firestore = await _futureFirebaseFirestore;
    yield* firestore
        .collection("users").doc(uid).snapshots()
        .map(
            (DocumentSnapshot<Map<String, dynamic>> snapshot) {
              return snapshot.data()?["last_updated"];
            }
    );
  }


}