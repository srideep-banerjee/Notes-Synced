import 'package:flutter/material.dart';
import 'package:notes_flutter/ui/home/profile_icon.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
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
      body: ListView.builder(
        itemCount: 50000,
        itemBuilder: (context, index) {
          return NotesItemDisplay(
            "Item: $index",
            onClick: () {
              
            },
          );
        },
      ),
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
