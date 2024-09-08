import 'package:flutter/material.dart';
import 'package:lan_sharing/lan_sharing.dart';
import 'dart:convert';

class LanServerFounder extends StatefulWidget {
  const LanServerFounder({super.key});

  @override
  State<LanServerFounder> createState() => _LanServerFounderState();
}

class _LanServerFounderState extends State<LanServerFounder> {
  String receivedMessage = '';

  late LanClient client = LanClient(onData: (data) {
    setState(() {
      receivedMessage = utf8.decode(data);
    });
  });

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      tryConnect();
    });
  }

  void tryConnect() async {
    await client.findServer();
  }

  @override
  void dispose() {
    client.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LanClientBuilder(
        lanClient: client,
        builder: (context, response) {
          if (response.state == ClientSocketStatus.connected) {
            return ListView(
              children: [
                Text('Server founded'),
                Text('Server IP: ${client.serverIp}:${client.port}'),
                Text('Received Message: $receivedMessage'),
                ElevatedButton(
                  onPressed: () {
                    client.sendMessage(
                      endpoint: '/test',
                      data: {},
                    );
                  },
                  child: const Text('Send Message'),
                ),
              ],
            );
          }

          if (response.state == ClientSocketStatus.disconnected) {
            return ListView(
              children: [
                Text('Server disconnected'),
                Text('Error: ${response.message}'),
              ],
            );
          }

          return const Text('Waiting for connection...');
        });
  }
}
