import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:notes_flutter/firebase/auth.dart';
import 'package:notes_flutter/ui/home/home_page.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    if (Provider.of<FirebaseApp?>(context) == null) {
      return const HomePage();
    }

    return StreamProvider<User?>.value(
      value: Authenticator().user,
      initialData: null,
      child: const HomePage(),
    );
  }
}
