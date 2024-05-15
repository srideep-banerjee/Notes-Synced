import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:notes_flutter/firebase/firebase_helper.dart';
import 'package:notes_flutter/firebase/firestore_helper.dart';
import 'package:notes_flutter/firebase/notes_change_model.dart';
import 'package:notes_flutter/local/database_local.dart';
import 'package:notes_flutter/local/note_model.dart';
import 'package:notes_flutter/local/preferences_helper.dart';
import 'package:notes_flutter/sync/sync_helper.dart';
import 'package:notes_flutter/ui/details/details_page.dart';
import 'package:notes_flutter/models/notes_item.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:notes_flutter/ui/home/notes_item_display.dart';
import 'package:notes_flutter/ui/home/profile_icon.dart';
import 'package:provider/provider.dart';
import 'package:notes_flutter/util/date_time_util.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {

  Future<List<NoteModel>>? notesListFuture;
  List<NoteModel> notesItemList = [];
  DatabaseHelper? databaseHelper;
  SyncHelper? syncHelper;
  Stream<List<NoteModel>>? notesStream;

  late Set<int> selectedIndices;

  @override
  void initState() {
    super.initState();
    print("Home page init called");
    selectedIndices = {};
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      print("addPostFrameCallback called");

      setState(() {
        print("Set state called");
        databaseHelper = Provider.of<DatabaseHelper>(context, listen: false);
        syncHelper = Provider.of<SyncHelper>(context, listen: false);
        // changesStream = syncHelper!.startRealtimeSync();
        notesStream = databaseHelper!.notesStream;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    print("Home page build called");
    return Scaffold(
      appBar: selectedIndices.isEmpty ? getDefaultAppBar(context) : getSelectionAppBar(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addItem(context);
        },
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<NoteModel>>(
        stream: notesStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.active) {
            print("Notes List is loading");
            return const Center(
              child: Text("Loading ..."),
            );
          }

          if (snapshot.hasError) {
            print("Error in notes stream: ${snapshot.error as Exception}");
          }

          if (snapshot.hasData) notesItemList = snapshot.data!;

          if (notesItemList.isEmpty) {
            print("List empty");
            return const Center(
                child: Text("No notes created")
            );
          }

          print("Displaying List");
          return homePageList();
        },
      )
    );
  }

  Widget homePageList() {
    return ListView.builder(
      itemCount: notesItemList.length,
      itemBuilder: (context, index) {
        return NotesItemDisplay(
          notesItemList[index].title,
          notesItemList[index].time,
          isSelected: selectedIndices.contains(index),
          onTap: () {
            if (selectedIndices.isNotEmpty) {
              if (selectedIndices.contains(index)) {
                setState(() {
                  selectedIndices.remove(index);
                });
              } else {
                setState(() {
                  selectedIndices.add(index);
                });
              }
            } else {
              _displayDetails(context, index);
            }
          },
          onDelete: () {
            _deleteItem(index);
          },
          onLongPress: () {
            setState(() {
              selectedIndices.add(index);
            });
          },
        );
      },
    );
  }

  Future<void> _addItem(BuildContext context) async {
    Future<NotesItem?> resultFuture = Navigator
        .of(context)
        .push(MaterialPageRoute(builder: (context) => const DetailsPage()));
    NotesItem? result = await resultFuture;
    if (result != null && databaseHelper != null) {
      syncHelper?.addNewNote(result);
      // String time = DateTime.timestamp().toString();
      // int index = await databaseHelper!.addNote(result, time);
      // setState(() {
      //   notesItemList.add(result.toNoteModel(index, time));
      // });
    }
  }

  Future<void> _displayDetails(BuildContext context, int index) async {
    NotesItem input = notesItemList[index].toNotesItem();
    Future<NotesItem?> resultFuture = Navigator
        .of(context)
        .push(MaterialPageRoute(builder: (context) => DetailsPage(notesItem: input)));
    NotesItem? result = await resultFuture;
    if (result != null) {
      String time = DateTime.timestamp().toString();
      NoteModel noteModel = result.toNoteModel(notesItemList[index].index, time);
      syncHelper?.updateNote(noteModel);
      // databaseHelper?.updateNote(noteModel);
      // setState(() {
      //   notesItemList[index] = noteModel;
      // });
    }
  }

  void _deleteSelectedItems() {

    databaseHelper?.deleteMultipleNotes(
        List.of(
            selectedIndices.map<int>((index) => notesItemList[index].index)
        )
    );

    setState(() {
      // List<int> rearrangedIndices = List.of(selectedIndices);
      // rearrangedIndices.sort((a, b) => b.compareTo(a));
      // for (int index in rearrangedIndices) {
      //   notesItemList.removeAt(index);
      // }
      // TODO: add deleteMultiple feature to sync helper
      selectedIndices.clear();
    });
  }

  void _deleteItem(int index) {

    databaseHelper?.deleteNote(notesItemList[index]);

    // setState(() {
    //   notesItemList.removeAt(index);
    // });
    // TODO: add deleteItem feature to sync helper
  }
  
  PreferredSizeWidget getDefaultAppBar(BuildContext context) {
    return AppBar(
      title: const Text("Notes"),
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
      actions: const [ProfileIcon()],
    );
  }

  PreferredSizeWidget getSelectionAppBar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          setState(() {
            selectedIndices.clear();
          });
        },
      ),
      title: Text("${selectedIndices.length} item selected"),
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
      actions: [
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: _deleteSelectedItems,
        )
      ],
    );
  }
}