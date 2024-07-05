import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';

class AuthProfileScreen extends StatelessWidget {
  final void Function() onSignOut;
  const AuthProfileScreen(this.onSignOut, {super.key});

  @override
  Widget build(BuildContext context) {
    return ProfileScreen(
      actions: [
        SignedOutAction((context) {
          onSignOut();
        }),
      ],
    );
  }
}
