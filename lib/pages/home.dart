import 'dart:io';
import 'dart:math';

import 'package:band_names/models/band.dart';
import 'package:band_names/services/socket_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Band> bands = [];

  @override
  void initState() {
    final socketService = Provider.of<SocketService>(context, listen: false);

    socketService.socket.on('bands', (data) {
      bands.clear();
      (data['bands'] as List<dynamic>).forEach((element) {
        bands.add(Band.fromMap(element));
      });
      setState(() {});
    });

    super.initState();
  }

  @override
  void dispose() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.off('bands');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        actions: [
          Container(
              margin: const EdgeInsets.only(right: 10),
              child: (socketService.serverStatus == ServerStatus.Online)
                  ? const Icon(Icons.check_circle, color: Colors.blue)
                  : const Icon(Icons.network_check, color: Colors.red))
        ],
        title: const Text(
          'BandNames',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
      ),
      body: ListView.builder(
          itemCount: bands.length, itemBuilder: (_, i) => _bandTile(bands[i])),
      floatingActionButton: FloatingActionButton(
        onPressed: addNewBand,
        child: const Icon(Icons.add),
        elevation: 0,
      ),
    );
  }

  Widget _bandTile(Band band) {
    final socketService = Provider.of<SocketService>(context, listen: false);

    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      onDismissed: (direction) {
        print('LOG  ${1}');
      },
      background: GestureDetector(
        child: Container(
          padding: const EdgeInsets.only(left: 8.0),
          color: Colors.red,
          child: const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Delete Band',
                style: TextStyle(color: Colors.white),
              )),
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue[100],
          child: Text(band.name.substring(0, 2)),
        ),
        title: Text(band.name),
        trailing: Text(
          band.votes.toString(),
          style: const TextStyle(fontSize: 20),
        ),
        onTap: () {
          print('LOG  ${1}');
          socketService.socket.emit('addvote', band.id);
        },
      ),
    );
  }

  addNewBand() {
    final socketService = Provider.of<SocketService>(context, listen: false);

    final textController = TextEditingController();

    if (Platform.isAndroid) {
      showDialog(
          context: context,
          builder: (_) {
            return AlertDialog(
              title: const Text('New band name: '),
              content: TextField(
                controller: textController,
              ),
              actions: [
                MaterialButton(
                  onPressed: () => addBand(textController.text, socketService),
                  textColor: Colors.indigo,
                  elevation: 5,
                  child: const Text('Add'),
                )
              ],
            );
          });
      return;
    } else {
      showCupertinoDialog(
          context: context,
          builder: (_) {
            return CupertinoAlertDialog(
              title: const Text('New band name: '),
              content: CupertinoTextField(
                controller: textController,
              ),
              actions: [
                CupertinoDialogAction(
                  onPressed: () => addBand(textController.text, socketService),
                  isDefaultAction: true,
                  child: const Text('Add'),
                ),
                CupertinoDialogAction(
                  onPressed: () => Navigator.pop(context),
                  isDestructiveAction: true,
                  child: const Text('Dismiss'),
                )
              ],
            );
          });
    }
  }

  void addBand(String name, SocketService socketService) {
    if (name.length > 1) {
      socketService.socket.emit('addBand', name);
      bands.add(Band(id: '${bands.length}', name: name, votes: 3));
      // setState(() {});
    }

    Navigator.pop(context);
  }
}
