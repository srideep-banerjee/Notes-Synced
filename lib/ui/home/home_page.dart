import 'package:flutter/material.dart';
import 'package:notes_flutter/ui/details/details_page.dart';
import 'package:notes_flutter/ui/home/profile_icon.dart';
import 'package:notes_flutter/models/notes_item.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  late Future<void> notesListFuture;
  late List<NotesItem> notesItemList;

  @override
  void initState() {
    super.initState();
    notesListFuture = _createList(10);
  }

  @override
  Widget build(BuildContext context) {
    print("Home page build called");
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notes"),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: const [ProfileIcon()],
      ),
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
                  onClick: () {
                    _displayDetails(context, index);
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
}

class NotesItemDisplay extends StatelessWidget {
  final String title;
  final Function onClick;

  NotesItemDisplay(
    this.title, {
    super.key,
    Function? onClick,
  }) : onClick = onClick ?? (() {});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onClick();
      },
      child: Text(title),
    );
  }
}
