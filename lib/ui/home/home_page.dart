import 'package:flutter/material.dart';
import 'package:notes_flutter/ui/details/details_page.dart';
import 'package:notes_flutter/ui/home/profile_icon.dart';
import 'package:notes_flutter/models/notes_item.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  late Future<void> notesListFuture;
  late List<NotesItem> notesItemList;

  late Set<int> selectedIndices;

  @override
  void initState() {
    super.initState();
    notesListFuture = _createList(10);
    selectedIndices = {};
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
          if (snapshot.connectionState == ConnectionState.done) {
            print("Displaying List");

            if (notesItemList.isEmpty) {
              return const Center(
                child: Text("No notes created")
              );
            }

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
                    deleteItem(index);
                  },
                  onLongPress: () {
                    setState(() {
                      selectedIndices.add(index);
                    });
                  },
                );
              },
            );
          } else {
            print("Notes List is loading");
            return const Center(
              child: Text("Loading ...")
            );
          }
        },
      ),
    );
  }

  Future<void> _createList(int length) async {
    notesItemList = List<NotesItem>.generate(
        length, (index) => NotesItem(title: "title $index", content: "content $index")
    );
  }

  Future<void> _addItem(BuildContext context) async {
    Future<NotesItem?> resultFuture = Navigator
        .of(context)
        .push(MaterialPageRoute(builder: (context) => const DetailsPage()));
    NotesItem? result = await resultFuture;
    setState(() {
      if (context.mounted && result != null) {
        notesItemList.add(result);
      }
    });
  }

  Future<void> _displayDetails(BuildContext context, int index) async {
    NotesItem input = notesItemList[index];
    Future<NotesItem?> resultFuture = Navigator
        .of(context)
        .push(MaterialPageRoute(builder: (context) => DetailsPage(notesItem: input)));
    NotesItem? result = await resultFuture;
    setState(() {
      if (context.mounted && result != null) {
        notesItemList[index] = result;
      }
    });
  }

  void deleteItems() {
    setState(() {
      for (int index in selectedIndices) {
        notesItemList.removeAt(index);
      }
      selectedIndices.clear();
    });
  }

  void deleteItem(int index) {
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
          onPressed: deleteItems,
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
