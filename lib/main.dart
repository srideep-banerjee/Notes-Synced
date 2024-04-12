import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:notes_flutter/firebase_options.dart';
import 'package:notes_flutter/local/database_local.dart';
import 'package:notes_flutter/ui/wrapper.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue.shade800),
        useMaterial3: true,
      ),
      home: MultiProvider(
        providers: [
          FutureProvider<FirebaseApp?>.value(
            value: Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
            initialData: null,
          ),
          Provider<DatabaseHelper>(
            create: (_) => DatabaseHelper(),
            dispose: (_, value) => value.dispose(),
          )
        ],
        child: const Wrapper(),
      ),
    );
  }
}