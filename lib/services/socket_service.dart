import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_client/socket_io_client.dart';

enum ServerStatus { Online, Offline, Connecting }

class SocketService with ChangeNotifier {
  ServerStatus _serverStatus = ServerStatus.Connecting;

  get serverStatus => _serverStatus;
  SocketService() {
    _initConfig();
  }

  void _initConfig() {
    Socket socket = io(
        'http://192.168.10.15:3000',
        OptionBuilder().setTransports(['websocket']) // for Flutter or Dart VM
            .build());

    socket.onConnect((_) {
      _serverStatus = ServerStatus.Online;
      notifyListeners();
      print('connect');
    });
    socket.onDisconnect((_) {
      _serverStatus = ServerStatus.Offline;
      notifyListeners();
      print('Disconnect');

    });
    socket.on('nuevo',(_) {
      _serverStatus = ServerStatus.Offline;
      notifyListeners();
      print('Nuevo mensaje');

    });
  }
}
