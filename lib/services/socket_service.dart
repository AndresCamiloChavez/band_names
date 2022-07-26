import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_client/socket_io_client.dart';

enum ServerStatus { Online, Offline, Connecting }

class SocketService with ChangeNotifier {
  ServerStatus _serverStatus = ServerStatus.Connecting;
  late Socket _socket;

  ServerStatus get serverStatus => _serverStatus;
  Socket get socket => _socket;

  SocketService() {
    _initConfig();
  }

  void _initConfig() {
   _socket = io(
        'http://192.168.0.6:3000',
        OptionBuilder().setTransports(['websocket']) // for Flutter or Dart VM
            .build());

    _socket.onConnect((_) {
      _serverStatus = ServerStatus.Online;
      notifyListeners();
      print('connect');
    });
    _socket.onDisconnect((_) {
      _serverStatus = ServerStatus.Offline;
      notifyListeners();
      print('Disconnect');
    });
    
    // socket.on('nuevo',(_) {
    //   _serverStatus = ServerStatus.Offline;
    //   notifyListeners();
    //   print('Nuevo mensaje');
    // });
  }
}
