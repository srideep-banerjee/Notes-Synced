import 'package:firebase_core/firebase_core.dart';
import 'package:notes_flutter/firebase/auth.dart';
import 'package:notes_flutter/firebase_options.dart';

class FirebaseHelper {
  late Future<FirebaseApp> _futureFirebaseApp;
  late Authenticator authenticator;

  FirebaseHelper(){
    _futureFirebaseApp = Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    authenticator = Authenticator(_futureFirebaseApp);
  }
}