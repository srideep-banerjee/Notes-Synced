import 'package:flutter/foundation.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class ConnectivityHelper {
  late Stream<InternetConnectionStatus> _connectivityStream;
  Stream<InternetConnectionStatus> get connectivityStream => _connectivityStream;

  ConnectivityHelper() {
    if (kIsWeb) {
      _connectivityStream = webStream();
    } else {
      _connectivityStream = InternetConnectionChecker().onStatusChange;
    }
  }

  Stream<InternetConnectionStatus> webStream() async* {
    yield InternetConnectionStatus.connected;
  }
}