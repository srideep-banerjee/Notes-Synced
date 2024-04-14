String getLocalizedTime(String time) {
  DateTime dateTime = DateTime.parse(time).toLocal();
  DateTime current = DateTime.now();
  Duration duration = current.difference(dateTime);
  if (duration.inSeconds < 5) {
    return "Just Now";
  } else if (duration.inSeconds < 60) {
    return "${duration.inSeconds} second${duration.inSeconds > 1 ? "s" : ""} ago";
  } else if (duration.inMinutes < 60) {
    return "${duration.inMinutes} minute${duration.inMinutes > 1 ? "s" : ""} ago";
  } else if (duration.inHours < 24) {
    return "${duration.inHours} hour${duration.inHours > 1 ? "s" : ""} ago";
  } else if (current.year == dateTime.year) {
    if (current.month == dateTime.month && current.day == dateTime.day + 1) {
      return "Yesterday at ${dateTime.hour}:${dateTime.minute~/10}${dateTime.minute%10}";
    } else {
      return "${_getMonth(dateTime.month)} ${dateTime.day} at ${dateTime.hour}:${dateTime.minute~/10}${dateTime.minute%10}";
    }
  } else {
    return "${_getMonth(dateTime.month)} ${dateTime.day}, ${dateTime.year} at ${dateTime.minute~/10}${dateTime.minute%10}";
  }
}

String _getMonth(int month) {
  switch (month) {
    case DateTime.january: return "Jan";
    case DateTime.february: return "Feb";
    case DateTime.march: return "Mar";
    case DateTime.april: return "Apr";
    case DateTime.may: return "May";
    case DateTime.june: return "Jun";
    case DateTime.july: return "Jul";
    case DateTime.august: return "Aug";
    case DateTime.september: return "Sep";
    case DateTime.october: return "Oct";
    case DateTime.november: return "Nov";
    case DateTime.december: return "Dec";
    default: return "None";
  }
}