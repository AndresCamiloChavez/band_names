import 'dart:io';

import 'package:band_names/models/band.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Band> bands = [
    Band(id: '1', name: 'Metalica', votes: 5),
    Band(id: '2', name: 'Heroes del silencio', votes: 2),
    Band(id: '3', name: 'Bon Jovi', votes: 3),
    Band(id: '4', name: 'Queen', votes: 2),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
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
    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      onDismissed: (direction){
        
      },
      background: Container(
        padding:  const EdgeInsets.only(left: 8.0),
        color: Colors.red,
        child: const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Delete Band',
              style: TextStyle(color: Colors.white),
            )),
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
        onTap: () {},
      ),
    );
  }

  addNewBand() {
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
                  onPressed: () => addBand(textController.text),
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
                  onPressed: () => addBand(textController.text),
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

  void addBand(String name) {
    if (name.length > 1) {
      bands.add(Band(id: '${bands.length}', name: name, votes: 3));
      setState(() {});
    }

    Navigator.pop(context);
  }
}
