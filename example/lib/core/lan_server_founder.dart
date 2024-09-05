import 'package:flutter/material.dart';
import 'package:lan_sharing/lan_sharing.dart';

class LanServerFounder extends StatefulWidget {
  const LanServerFounder({super.key});

  @override
  State<LanServerFounder> createState() => _LanServerFounderState();
}

class _LanServerFounderState extends State<LanServerFounder> {
  LanClient client = LanClient(
      port: 3000,
      onMessage: (message) {
        print(message);
      });
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    tryConnect();
  }

  void tryConnect() async {
    setState(() {
      isLoading = true;
    });
    await client.findServer();
    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    client.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: const CircularProgressIndicator());
    }

    return Column(
      children: [
        Text('Server founded'),
        StreamBuilder(
          stream: client.stateStream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Text(snapshot.data!.name);
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return Text('Waiting for connection...');
            }
          },
        ),
        Text(client.socket?.remoteAddress.address ?? ''),
        ElevatedButton(
          onPressed: () async {
            await client.sendMessage(
                endpoint: '/test', data: {'message': 'Hello Server!'});
          },
          child: const Text('Send message'),
        ),
      ],
    );
  }
}
