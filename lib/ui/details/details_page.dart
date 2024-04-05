import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notes_flutter/default_settings.dart';
import 'package:notes_flutter/models/notes_item.dart';

class DetailsPage extends StatefulWidget {
  final NotesItem? notesItem;

  const DetailsPage({this.notesItem, super.key});

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {

  late TextEditingController titleController, bodyController;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.notesItem?.title);
    bodyController = TextEditingController(text: widget.notesItem?.content);
  }

  @override
  void dispose() {
    titleController.dispose();
    bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Details"),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            NotesItem input = widget.notesItem??const NotesItem(title: "", content: "");
            if (titleController.text != "" && (titleController.text != input.title || bodyController.text != input.content)) {
              Navigator.pop(context, NotesItem(title: titleController.text, content: bodyController.text));
            } else {
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.save,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            onPressed: () {

            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TitleText(titleController),
            const Divider(),
            Expanded(
              child: BodyText(bodyController),
            ),
          ],
        ),
      ),
    );
  }
}

class TitleText extends StatelessWidget {

  final TextEditingController controller;

  const TitleText(this.controller, {super.key});

  @override
  Widget build(BuildContext context) {
    return TextField(
      maxLines: null,
      expands: false,
      maxLengthEnforcement: MaxLengthEnforcement.enforced,
      controller: controller,
      decoration: const InputDecoration.collapsed(
        hintText: "Title",
      ),
      inputFormatters: [
        LengthLimitingTextInputFormatter(DefaultSettings.maxTitleLength),
        FilteringTextInputFormatter.deny(RegExp(r"\n")),
      ],
      style: const TextStyle(fontSize: 30.0),
    );
  }
}

class BodyText extends StatelessWidget {

  final TextEditingController controller;

  const BodyText(this.controller, {super.key});

  @override
  Widget build(BuildContext context) {
    return TextField(
      maxLines: null,
      expands: false,
      maxLengthEnforcement: MaxLengthEnforcement.enforced,
      controller: controller,
      decoration: const InputDecoration.collapsed(
        hintText: "Body",
      ),
      inputFormatters: [
        LengthLimitingTextInputFormatter(DefaultSettings.maxBodyLength),
      ],
    );
  }
}
