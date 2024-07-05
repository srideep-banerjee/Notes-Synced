import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notes_flutter/secrets.dart';

class AuthSignInScreen extends StatelessWidget {
  final void Function(User? user) onSignIn;
  const AuthSignInScreen(this.onSignIn, {super.key});

  @override
  Widget build(BuildContext context) {
    return SignInScreen(
      showAuthActionSwitch: true,
      showPasswordVisibilityToggle: true,
      providers: [
        GoogleProvider(clientId: webClientId)
      ],
      actions: [
        AuthStateChangeAction<SignedIn>((context, state) {
          onSignIn(state.user);
        }),
        AuthStateChangeAction<AuthFailed>((context, state) {
          ErrorText.localizeError = (BuildContext context, FirebaseAuthException e) {
            return switch (e.code) {
              'user-not-found' || 'wrong-password' => 'Email/Password incorrect',
              'credential-already-in-use' => 'This email is already in use.',
              _ => 'Something went wrong. code: ${e.code}',
            };
          };
          ErrorText.localizePlatformError = (BuildContext context, PlatformException e) {
            if (e.code == "network_error") return "Please check your internet connection.";
            return "Oh no! Something went wrong. code: ${e.code}";
          };
          if (state.exception is FirebaseAuthException) {
            FirebaseAuthException firebaseAuthException = state
                .exception as FirebaseAuthException;
            if (kDebugMode) {
              print("AUTH FAILED FAE CODE = ${firebaseAuthException.code}");
            }
          }
          if (state.exception is PlatformException) {
            PlatformException platformException = state
                .exception as PlatformException;
            if (kDebugMode) {
              print("AUTH FAILED PE CODE = ${platformException.code}");
            }
          }
        }),
      ],
    );
  }
}
