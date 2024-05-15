import 'package:firebase_core/firebase_core.dart';
import 'package:notes_flutter/firebase/auth.dart';
import 'package:notes_flutter/firebase/firebase_emulator.dart';
import 'package:notes_flutter/firebase/firestore_helper.dart';
import 'package:notes_flutter/firebase_options.dart';

class FirebaseHelper {
  late Future<FirebaseApp> _futureFirebaseApp;
  late Authenticator authenticator;
  late FirestoreHelper firestoreHelper;
  final FirebaseEmulator _firebaseEmulator = const FirebaseEmulator("192.168.207.102", 9099);

  FirebaseHelper(){
    _futureFirebaseApp = Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    authenticator = Authenticator(_futureFirebaseApp, _firebaseEmulator);
    firestoreHelper = FirestoreHelper(_futureFirebaseApp, _firebaseEmulator);
  }
}