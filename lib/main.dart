import 'package:flutter/material.dart';
import 'package:notes_flutter/firebase/auth.dart';
import 'package:notes_flutter/firebase/firebase_helper.dart';
import 'package:notes_flutter/firebase/firestore_helper.dart';
import 'package:notes_flutter/local/database_local.dart';
import 'package:notes_flutter/local/preferences_helper.dart';
import 'package:notes_flutter/sync/sync_helper.dart';
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
  late PreferencesHelper _preferencesHelper;
  late FirebaseHelper _firebaseHelper;
  late FirestoreHelper _firestoreHelper;
  late Authenticator _authenticator;
  late SyncHelper _syncHelper;

  @override
  void initState() {
    super.initState();
    _databaseHelper = DatabaseHelper();
    _preferencesHelper = PreferencesHelper();
    _firebaseHelper = FirebaseHelper();
    _firestoreHelper = _firebaseHelper.firestoreHelper;
    _authenticator = _firebaseHelper.authenticator;
    _syncHelper = SyncHelper(_databaseHelper, _firebaseHelper, _preferencesHelper);
  }

  @override
  void dispose() {
    _syncHelper.dispose();
    _databaseHelper.dispose();
    super.dispose();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Notes Flutter',
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
          Provider<PreferencesHelper>.value(
            value: _preferencesHelper,
            updateShouldNotify: (_,__) => false,
          ),
          Provider<FirestoreHelper>.value(
            value: _firestoreHelper,
            updateShouldNotify: (_,__) => false,
          ),
          Provider<Authenticator>.value(
            value: _authenticator,
            updateShouldNotify: (_,__) => false,
          ),
          Provider<SyncHelper>.value(
            value: _syncHelper,
            updateShouldNotify: (_,__) => false,
          ),
        ],
        child: const HomePage(),
      ),
    );
  }
}