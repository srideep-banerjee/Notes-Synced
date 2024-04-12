import 'package:flutter/material.dart';
import 'package:notes_flutter/local/database_local.dart';
import 'package:notes_flutter/local/note_model.dart';
import 'package:notes_flutter/ui/details/details_page.dart';
import 'package:notes_flutter/models/notes_item.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:notes_flutter/ui/home/profile_icon.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {

  Future<List<NoteModel>>? notesListFuture;
  DatabaseHelper? databaseHelper;
  List<NoteModel> notesItemList = [];

  late Set<int> selectedIndices;

  @override
  void initState() {
    super.initState();
    print("Home page init called");
    selectedIndices = {};
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        databaseHelper = Provider.of<DatabaseHelper>(context, listen: false);
        notesListFuture = databaseHelper?.getNoteList();
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
      body: FutureBuilder(
        future: notesListFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            print("Notes List is loading");
            return const Center(
              child: Text("Loading ..."),
            );
          }

          if (snapshot.hasData) notesItemList = snapshot.data!;

          if (notesItemList.isEmpty) {
            print("List empty");
            return const Center(
                child: Text("No notes created")
            );
          }

          print("Displaying List");
          return ListView.builder(
            itemCount: notesItemList.length,
            itemBuilder: (context, index) {
              return NotesItemDisplay(
                notesItemList[index].title,
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
        },
      ),
    );
  }

  Future<void> _addItem(BuildContext context) async {
    Future<NotesItem?> resultFuture = Navigator
        .of(context)
        .push(MaterialPageRoute(builder: (context) => const DetailsPage()));
    NotesItem? result = await resultFuture;
    if (result != null && databaseHelper != null) {
      int index = await databaseHelper!.addNote(result);
      setState(() {
        notesItemList.add(result.toNoteModel(index));
      });
    }
  }

  Future<void> _displayDetails(BuildContext context, int index) async {
    NotesItem input = notesItemList[index].toNotesItem();
    Future<NotesItem?> resultFuture = Navigator
        .of(context)
        .push(MaterialPageRoute(builder: (context) => DetailsPage(notesItem: input)));
    NoteModel? result = (await resultFuture)?.toNoteModel(notesItemList[index].index);
    if (result != null) {
      databaseHelper?.updateNote(result);
      setState(() {
        notesItemList[index] = result;
      });
    }
  }

  void _deleteSelectedItems() {

    databaseHelper?.deleteMultipleNotes(selectedIndices.map<int>((index) => notesItemList[index].index));

    setState(() {
      for (int index in selectedIndices) {
        notesItemList.removeAt(index);
      }
      selectedIndices.clear();
    });
  }

  void _deleteItem(int index) {

    databaseHelper?.deleteNote(notesItemList[index]);

    setState(() {
      notesItemList.removeAt(index);
    });
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

class NotesItemDisplay extends StatefulWidget {
  final String title;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onLongPress;
  final bool isSelected;

  NotesItemDisplay(
    this.title,
      {
        super.key,
        this.isSelected = false,
        VoidCallback? onTap,
        VoidCallback? onDelete,
        VoidCallback? onLongPress,
      }
      ) :
        onTap = onTap ?? (() {}),
        onDelete = onDelete ?? (() {}),
        onLongPress = onLongPress ?? (() {});

  @override
  State<NotesItemDisplay> createState() => _NotesItemDisplayState();
}

class _NotesItemDisplayState extends State<NotesItemDisplay> {

  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          isHovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          isHovered = false;
        });
      },
      child: GestureDetector(
        onTap: () {
          widget.onTap();
        },
        onLongPress: () {
          if(!kIsWeb) widget.onLongPress();
        },
        child: Row(
          children: [
            Expanded(child: Text(widget.title)),
            if (kIsWeb && isHovered) IconButton(
              onPressed: widget.onDelete,
              icon: const Icon(Icons.delete),
            ),
            if (!kIsWeb && widget.isSelected) const Icon(Icons.check_circle)
          ],
        ),
      ),
    );
  }
}
