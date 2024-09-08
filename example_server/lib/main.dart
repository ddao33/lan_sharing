import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:lan_sharing/lan_sharing.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final lanServer = LanServer()
    ..start()
    ..addEndpoint('/test', (socket, request) {
      final response = jsonEncode({'from': '/test', 'message': '测试endpoint'});
      socket.addUtf8String(response);
    });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Home'),
        ),
        body: LanServerBuilder(
          lanServer: lanServer,
          builder: (context, state, connectedIps) {
            return Center(
              child: Column(
                children: [
                  Text('Server is ${state.name}'),
                  Text('Connected IPs: $connectedIps'),
                  ElevatedButton(
                    onPressed: () {
                      lanServer.stop();
                    },
                    child: const Text('Stop'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      lanServer.start();
                    },
                    child: const Text('Start'),
                  )
                ],
              ),
            );
          },
        ));
  }
}
