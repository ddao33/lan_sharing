import 'package:flutter/material.dart';
import 'package:lan_sharing/lan_sharing.dart';

class LanServerBuilder extends StatefulWidget {
  const LanServerBuilder({
    super.key,
    required this.lanServer,
    required this.builder,
  });

  final LanServer lanServer;
  final Widget Function(
          BuildContext context, LanServerState state, Set<String> connectedIps)
      builder;

  @override
  State<LanServerBuilder> createState() => _LanServerBuilderState();
}

class _LanServerBuilderState extends State<LanServerBuilder> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<LanServerState>(
      stream: widget.lanServer.stateStream,
      builder: (context, stateSnapshot) {
        return StreamBuilder<Set<String>>(
          stream: widget.lanServer.connectedClientsStream,
          builder: (context, clientsSnapshot) {
            final state = stateSnapshot.data ?? LanServerState.stopped;
            final connectedIps = clientsSnapshot.data ?? <String>{};
            return widget.builder(context, state, connectedIps);
          },
        );
      },
    );
  }
}
