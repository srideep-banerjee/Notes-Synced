import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:notes_flutter/local/database_local.dart';
import 'package:notes_flutter/local/note_model.dart';
import 'package:notes_flutter/sync/sync_helper.dart';
import 'package:notes_flutter/ui/details/details_page.dart';
import 'package:notes_flutter/models/notes_item.dart';
import 'package:notes_flutter/ui/home/notes_item_display.dart';
import 'package:notes_flutter/ui/home/profile_icon.dart';
import 'package:provider/provider.dart';

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
    selectedIndices = {};
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {

      setState(() {
        databaseHelper = Provider.of<DatabaseHelper>(context, listen: false);
        syncHelper = Provider.of<SyncHelper>(context, listen: false);
        // changesStream = syncHelper!.startRealtimeSync();
        notesStream = databaseHelper!.notesStream;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print("Home page build called");
    }
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
            if (kDebugMode) {
              print("Notes List is loading");
            }
            return const Center(
              child: Text("Loading ..."),
            );
          }

          if (snapshot.hasError && kDebugMode) {
            print("Error in notes stream: ${snapshot.error as Exception}");
          }

          if (snapshot.hasData) notesItemList = snapshot.data!;

          if (notesItemList.isEmpty) {
            if (kDebugMode) {
              print("List empty");
            }
            return const Center(
                child: Text("No notes created")
            );
          }

          if (kDebugMode) {
            print("Displaying List");
          }
          return homePageList();
        },
      )
    );
  }

  Widget homePageList() {
    return ListView.separated(
      padding: const EdgeInsets.all(8.0),
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
      separatorBuilder: (BuildContext context, int index) {
        return const SizedBox(height: 8.0);
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
      String? firestoreId = notesItemList[index].firestoreId;
      if (firestoreId != null) {
        noteModel = noteModel.setFirestoreId(firestoreId);
      }
      syncHelper?.updateNote(noteModel);
    }
  }

  void _deleteSelectedItems() {

    List<NoteModel> selectedNotes = List.of(
      selectedIndices.map((e) => notesItemList[e]),
    );
    syncHelper?.deleteMultipleNotes(selectedNotes);
    selectedIndices.clear();
  }

  void _deleteItem(int index) {
    syncHelper?.deleteNote(notesItemList[index]);
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