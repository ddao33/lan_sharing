import 'package:example/lan_server_builder.dart';
import 'package:flutter/material.dart';
import 'package:lan_sharing/lan_sharing.dart';

class AppServer extends StatelessWidget {
  const AppServer({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const _HomeScreen(),
    );
  }
}

class _HomeScreen extends StatefulWidget {
  const _HomeScreen({super.key});

  @override
  State<_HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<_HomeScreen> {
  LanServer server = LanServer(port: 3000);

  @override
  void initState() {
    super.initState();
    startServer();
  }

  @override
  void dispose() {
    server.dispose();
    super.dispose();
  }

  startServer() async {
    await server.start();
    server.addEndpoint('/test', (socket, data) {
      socket.add('Hello THIS IS FROM TEST'.codeUnits);
      socket.flush();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: LanServerBuilder(
        lanServer: server,
        builder: (context, state, connectedIps) {
          return Column(
            children: [
              Text('Server State: $state'),
              Text('Connected IPs: $connectedIps'),
            ],
          );
        },
      ),
    );
  }
}
