import 'package:band_names/services/socket_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StatusPage extends StatelessWidget {
  const StatusPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final socketProvider = Provider.of<SocketService>(context);
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Text('Server status: ${socketProvider.serverStatus}'),
          ],
        ),
      ),
    );
  }
}