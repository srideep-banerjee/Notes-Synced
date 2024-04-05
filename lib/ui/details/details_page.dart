import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notes_flutter/default_settings.dart';

class DetailsPage extends StatelessWidget {
  const DetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Details"),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {},
        ),
      ),
      body: const Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: [
            TitleText(),
            Divider(),
            Expanded(
              child: BodyText(),
            ),
          ],
        ),
      ),
    );
  }
}

class TitleText extends StatefulWidget {
  const TitleText({super.key});

  @override
  State<TitleText> createState() => _TitleTextState();
}

class _TitleTextState extends State<TitleText> {
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

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

class BodyText extends StatefulWidget {
  const BodyText({super.key});

  @override
  State<BodyText> createState() => _BodyTextState();
}

class _BodyTextState extends State<BodyText> {
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

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
