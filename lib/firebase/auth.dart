import 'package:firebase_auth/firebase_auth.dart' as fb;

class Authenticator {

  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;

  Stream<User?> get user {
    return _auth.authStateChanges().map(firebaseUserToUser);
  }

  User? firebaseUserToUser(fb.User? user) {
    return user != null ? User(uid: user.uid) : null;
  }
}

class User {
  final String uid;
  User({required this.uid});
}