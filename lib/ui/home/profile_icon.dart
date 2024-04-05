import 'package:flutter/material.dart';
import 'package:notes_flutter/firebase/auth.dart';
import 'package:provider/provider.dart';

class ProfileIcon extends StatefulWidget {
  const ProfileIcon({super.key});

  @override
  State<ProfileIcon> createState() => _ProfileIconState();
}

class _ProfileIconState extends State<ProfileIcon> {

  String text = "";
  Color? _colorValue;

  Color get _color {
    _colorValue ??= HSLColor
        .fromAHSL(1.0, (_customHash % 361).toDouble(), 1.0, 0.35,)
        .toColor();
    return _colorValue!;
  }

  Color? _borderColorValue;
  Color get _borderColor {
    _borderColorValue ??= HSLColor
        .fromAHSL(1.0, (_customHash % 361).toDouble(), 1.0, 0.25,)
        .toColor();
    return _borderColorValue!;
  }

  int? _customHashValue;
  int get _customHash {
    if (_customHashValue != null) {
      return _customHashValue!;
    }
    int hash = 0;
    for (int i = 0; i < text.length; i++) {
      hash += (i + 1) * text.codeUnitAt(i);
    }
    _customHashValue = hash;
    return hash;
  }

  @override
  Widget build(BuildContext context) {
    User? user = Provider.of<User?>(context);
    if (user?.email != null && user?.email != text) {
      text = (user?.email)!;
      _customHashValue = null;
      _borderColorValue = null;
      _colorValue = null;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Container(
        width: 32.0,
        height: 32.0,
        decoration: BoxDecoration(
            color: user == null ? Colors.transparent: _color,
            shape: BoxShape.circle,
            border: Border.all(
              color: user == null ?
              Theme.of(context).colorScheme.onPrimary: _borderColor,
              width: user == null ? 2.0 : 1.0,
            )
        ),
        child: user == null ?
        const DefaultProfileIconImage() : TextProfileIconImage(text),
      ),
    );
  }
}

class DefaultProfileIconImage extends StatelessWidget {
  const DefaultProfileIconImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.person, color: Theme.of(context).colorScheme.onPrimary);
  }
}

class TextProfileIconImage extends StatelessWidget {

  final String text;

  const TextProfileIconImage(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        text.substring(0,1).toUpperCase(),
        style: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary,
          fontSize: 20.0,
        ),
      ),
    );
  }
}