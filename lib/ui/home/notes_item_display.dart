import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:notes_flutter/util/date_time_util.dart';

class NotesItemDisplay extends StatefulWidget {
  final String title;
  final String time;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onLongPress;
  final bool isSelected;

  NotesItemDisplay(
      this.title,
      String time,
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
        onLongPress = onLongPress ?? (() {}),
        time = getLocalizedTime(time);

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
            if (!kIsWeb && widget.isSelected) const Icon(Icons.check_circle),
            Text(widget.time),
          ],
        ),
      ),
    );
  }
}
