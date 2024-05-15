import 'dart:async';

import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:notes_flutter/firebase/auth.dart';
import 'package:notes_flutter/firebase/notes_change_model.dart';

class SyncStream {

  late Stream<List<NotesChangeModel>> _resultStream;

  SyncStream(
      Stream<User?> userStream,
      Stream<InternetConnectionStatus> connectionStream,
      Stream<List<NotesChangeModel>> Function(User) userToChangeStreamConverter,
      [
        Future<void> Function(User?)? onUserChange,
        Future<void> Function(InternetConnectionStatus)? onConnectionChange
      ]
      ) {

    StreamController<List<NotesChangeModel>> controller = StreamController();
    Sink<List<NotesChangeModel>> resultSink = controller.sink;
    _resultStream = controller.stream;

    StreamSubscription<User?>? userStreamSub;
    StreamSubscription<List<NotesChangeModel>>? changesStreamSub;
    StreamSubscription<InternetConnectionStatus>? connectionStreamSub;

    controller.onListen = () {
      userStreamSub = userStream.listen((user) async {
        print("USER EVENT OCCURRED");

        changesStreamSub?.cancel();

        if (onUserChange != null) await onUserChange(user);

        if (user != null) {
          changesStreamSub = userToChangeStreamConverter(user)
              .listen(resultSink.add);
        }
      });

      connectionStreamSub = connectionStream.listen((connected) async {
        print("CONNECTION EVENT OCCURRED");

        if (onConnectionChange != null) {
          await onConnectionChange(connected);
        }

        if (connected == InternetConnectionStatus.connected) {
          changesStreamSub?.resume();
        } else {
          changesStreamSub?.pause();
        }
      });
    };

    controller.onCancel = () {
      print("Sync stream controller is cancelling");
      userStreamSub?.cancel();
      connectionStreamSub?.cancel();
      changesStreamSub?.cancel();
    };

    controller.onPause = () {
      userStreamSub?.pause();
      connectionStreamSub?.pause();
    };

    controller.onResume = () {
      userStreamSub?.resume();
      connectionStreamSub?.resume();
    };
  }

  get stream => _resultStream;
}