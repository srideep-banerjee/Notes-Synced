import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_core/firebase_core.dart';

class Authenticator {

  final Future<fb.FirebaseAuth> _futureFirebaseAuth;

  Authenticator(Future<FirebaseApp> futureFirebaseApp):
        _futureFirebaseAuth = futureFirebaseApp.
        then((_) => fb.FirebaseAuth.instance);

  Stream<User?> getUserStream() async* {
    fb.FirebaseAuth auth = await _futureFirebaseAuth;
    yield* auth.authStateChanges().map(_firebaseUserToUser);
  }

  User? _firebaseUserToUser(fb.User? user) {
    return user != null ? User(uid: user.uid, email: user.email!, photoUrl: user.photoURL) : null;
  }
}

class User {
  final String uid;
  final String email;
  final String? photoUrl;
  User({required this.uid, required this.email, required this.photoUrl});
}