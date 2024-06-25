import 'dart:async';

import 'package:flutter/foundation.dart';

class MultiUseStream<T> {
  _MultiUseStreamDataHolder<T>? _lastData;
  late Stream<T> _origin;
  StreamSubscription<T>? _lastOriginSubscription;

  MultiUseStream(Stream<T> origin) {
    this._origin = origin.asBroadcastStream(
      onListen: (subscription) {
        if (kDebugMode) {
          print("listening to multiStream");
        }
        _lastOriginSubscription = subscription;
        subscription.resume();
      },
      onCancel: (subscription) {
        _lastOriginSubscription = subscription;
        subscription.pause();
      },
    );
  }

  Stream<T> stream() async* {
    if (_lastData != null) {
      yield _lastData!.data;
    }
    await for (T data in _origin) {
      _lastData = _MultiUseStreamDataHolder(data);
      yield data;
    }
  }

  void close() {
    _lastOriginSubscription?.cancel();
  }
}

class _MultiUseStreamDataHolder<T> {
  T data;
  _MultiUseStreamDataHolder(this.data);
}
