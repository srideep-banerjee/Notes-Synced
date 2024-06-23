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
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withAlpha(51),
            borderRadius: const BorderRadius.all(Radius.circular(8))
          ),
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(widget.time, style: Theme.of(context).textTheme.labelSmall),
                  ],
                ),
              ),
              if (kIsWeb && isHovered) SizedBox(
                height: 24,
                child: IconButton(
                  padding: const EdgeInsets.all(0.0),
                  onPressed: widget.onDelete,
                  icon: Icon(
                    Icons.delete_rounded,
                    color: Theme.of(context).primaryColor,
                    size: 24,
                  ),
                ),
              ),
              if (!kIsWeb && widget.isSelected) SizedBox(
                height: 24,
                child: IconButton(
                  padding: const EdgeInsets.all(0.0),
                  onPressed: widget.onDelete,
                  icon: Icon(
                    Icons.check_circle,
                    color: Theme.of(context).primaryColor,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
