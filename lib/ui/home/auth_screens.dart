import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notes_flutter/secrets.dart';

class AuthScreenContainer extends StatelessWidget {
  final AuthScreen authScreen;
  const AuthScreenContainer(this.authScreen , {super.key,});

  @override
  Widget build(BuildContext context) {

    Widget child = switch (authScreen) {
      AuthScreen.profile => _profileScreen(),
      AuthScreen.signIn => _signInScreen()
    };

    return Container(
      color: Theme.of(context).canvasColor,
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > constraints.maxHeight) {
            return Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                Expanded(child: child)
              ],
            );
          } else {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0.0, 16.0, 0.0, 0.0),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                Expanded(child: child)
              ],
            );
          }
        },
      ),
    );
  }

  Widget _signInScreen() {
    return SignInScreen(
      showAuthActionSwitch: true,
      showPasswordVisibilityToggle: true,
      providers: [
        GoogleProvider(clientId: webClientId)
      ],
      actions: [
        AuthStateChangeAction<SignedIn>((context, state) {
          if (state.user == null || state.user?.emailVerified == true) {
            Navigator.pop(context);
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context2) => const AuthScreenContainer(
                  AuthScreen.profile,
                ),
              )

            );
          }
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

  Widget _profileScreen() {
    return ProfileScreen(
      actions: [
        SignedOutAction((context) {
          Navigator.pop(context);
        }),
        // AuthStateChangeAction<AuthState>((context, state) {
        //   print("ProfileScreen state change : ${state.runtimeType}");
        // })
      ],
    );
  }
}

enum AuthScreen {
  profile,
  signIn,
}
