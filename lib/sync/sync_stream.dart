import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:notes_flutter/firebase/auth.dart';

class SyncStream<T> {

  late Stream<T> _resultStream;

  SyncStream(
      Stream<User?> userStream,
      Stream<InternetConnectionStatus> connectionStream,
      Stream<T> Function(User) userToStreamConverter,
      [
        Future<void> Function(User?)? onUserChange,
        Future<void> Function(InternetConnectionStatus)? onConnectionChange
      ]
      ) {

    StreamController<T> controller = StreamController();
    Sink<T> resultSink = controller.sink;
    _resultStream = controller.stream;

    StreamSubscription<User?>? userStreamSub;
    StreamSubscription<T>? changesStreamSub;
    StreamSubscription<InternetConnectionStatus>? connectionStreamSub;

    controller.onListen = () {
      userStreamSub = userStream.listen((user) async {
        if (kDebugMode) {
          print("USER EVENT OCCURRED");
        }

        changesStreamSub?.cancel();

        if (onUserChange != null) await onUserChange(user);

        if (user != null) {
          changesStreamSub = userToStreamConverter(user)
              .listen(resultSink.add);
        }
      });

      connectionStreamSub = connectionStream.listen((connected) async {
        if (kDebugMode) {
          print("CONNECTION EVENT OCCURRED");
        }

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
      if (kDebugMode) {
        print("Sync stream controller is cancelling");
      }
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