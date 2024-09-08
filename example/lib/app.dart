import 'package:example/lan_server_founder.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LAN Sharing'),
      ),
      body: LanServerFounder(),
    );
  }
}
