import 'dart:io';
import 'dart:math';

import 'package:band_names/models/band.dart';
import 'package:band_names/services/socket_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
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

    socketService.socket.on('bands', _handlerActiveBands);

    super.initState();
  }

  _handlerActiveBands(dynamic data) {
    bands.clear();
    (data['bands'] as List<dynamic>).forEach((element) {
      bands.add(Band.fromMap(element));
    });
    setState(() {});
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
          'Name',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          if(bands.length > 0)
          Container(
            width: double.infinity,
            height: 200,
            child: _showGraph(),
          ),
          Expanded(
            child: ListView.builder(
                itemCount: bands.length,
                itemBuilder: (_, i) => _bandTile(bands[i])),
          ),
        ],
      ),
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
        socketService.socket.emit('delete-band', band.id);
        print('LOG eliminar banda ${band.id}');
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
              title: const Text('New name: '),
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
    }

    Navigator.pop(context);
  }

  Widget _showGraph() {
    Map<String, double> dataMap = {
      // "Flutter": 5,
      // "React": 3,
      // "Xamarin": 2,
      // "Ionic": 2,
    };
    bands.forEach((element) {
      dataMap.putIfAbsent(element.name, () => element.votes.toDouble());
    });
    final List<Color> colorList = [
      Color(0xff23424f),
      Color.fromARGB(255, 49, 151, 195),
      Color.fromARGB(255, 23, 136, 185),
      Color.fromARGB(255, 16, 115, 157),
      Color.fromARGB(255, 189, 217, 229)
    ];
    return PieChart(
      dataMap: dataMap,
      animationDuration: Duration(milliseconds: 800),
      chartLegendSpacing: 32,
      chartRadius: MediaQuery.of(context).size.width / 3.2,
      colorList: colorList,
      initialAngleInDegree: 0,
      chartType: ChartType.ring,
      ringStrokeWidth: 32,
      centerText: "HYBRID",
      legendOptions: LegendOptions(
        showLegendsInRow: false,
        legendPosition: LegendPosition.right,
        showLegends: true,
        // legendShape: _BoxShape.circle,´
        legendTextStyle: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      chartValuesOptions: ChartValuesOptions(
        showChartValueBackground: true,
        showChartValues: true,
        showChartValuesInPercentage: false,
        showChartValuesOutside: false,
        decimalPlaces: 1,
      ),
      // gradientList: ---To add gradient colors---
      // emptyColorGradient: ---Empty Color gradient---
    );
  }
}
