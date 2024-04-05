import 'package:flutter/material.dart';
import 'package:notes_flutter/ui/home/profile_icon.dart';
import 'package:notes_flutter/models/notes_item.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  late Future<List<NotesItem>> notesListFuture;

  @override
  void initState() {
    super.initState();
    print("initState Started");
    notesListFuture = createList(10);
    print("initState complete");
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
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder(
        future: notesListFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            print("Displaying List");

            if (snapshot.data!.isEmpty) {
              return const Center(
                child: Text("No notes created")
              );
            }

            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return NotesItemDisplay(
                  snapshot.data![index].title,
                  onClick: () {
                    print("Item at index: $index clicked");
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

  Future<List<NotesItem>> createList(int length) async {
    return List<NotesItem>.generate(
        length, (index) => NotesItem(title: "title $index", content: "content $index")
    );
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
