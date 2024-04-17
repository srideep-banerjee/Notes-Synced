import 'package:flutter/material.dart';
import 'package:notes_flutter/firebase/auth.dart';
import 'package:notes_flutter/firebase/firebase_helper.dart';
import 'package:notes_flutter/firebase/firestore_helper.dart';
import 'package:notes_flutter/local/database_local.dart';
import 'package:notes_flutter/ui/home/home_page.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  late DatabaseHelper _databaseHelper;
  late FirebaseHelper _firebaseHelper;
  late FirestoreHelper _firestoreHelper;
  late Stream<User?> _userStream;

  @override
  void initState() {
    super.initState();
    _databaseHelper = DatabaseHelper();
    _firebaseHelper = FirebaseHelper();
    _userStream = _firebaseHelper.authenticator.getUserStream();
    _firestoreHelper = _firebaseHelper.firestoreHelper;
  }



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
          Provider<DatabaseHelper>.value(
            value: _databaseHelper,
            updateShouldNotify: (_,__) => false,
          ),
          Provider<FirestoreHelper>.value(
            value: _firestoreHelper,
            updateShouldNotify: (_,__) => false,
          ),
          StreamProvider<User?>.value(
            value: _userStream,
            initialData: null,
          )
        ],
        child: const HomePage(),
      ),
    );
  }
}