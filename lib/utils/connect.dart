import 'package:connectivity/connectivity.dart';
import 'dart:async';
import 'dart:io';

class NetworkConnectionStatus {

  NetworkConnectionStatus._internal();

  Connectivity connectivity = new Connectivity();

  static final NetworkConnectionStatus _instance = NetworkConnectionStatus._internal();

  static NetworkConnectionStatus get instance => _instance;

  StreamController controller = StreamController.broadcast();

  Stream get myStream => controller.stream;

  int _first = 0;
  int get first => _first;

  void init() async {
    ConnectivityResult result = await connectivity.checkConnectivity();
    controller.sink.add({
      'networkType': result,
      'networkStatus': await connectionStatus(result)
    });
    connectivity.onConnectivityChanged.listen((result) async {
      controller.sink.add({
        'networkType': result,
        'networkStatus': await connectionStatus(result)
      });
    });
  }

  Future<bool> connectionStatus(ConnectivityResult result) async {
    bool status = false;
    if (result == ConnectivityResult.none) {
      return status;
    } else {
      try {
        var result = await InternetAddress.lookup('www.google.com');
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          status = true;
          return status;
        } else {
          status = false;
          return status;
        }
      } on SocketException catch (_) {
        status = false;
        return status;
      }
    }
  }

  void changeStatus(int i) {
    _first = i;
  }

  void disposeStream() => controller.close();
}