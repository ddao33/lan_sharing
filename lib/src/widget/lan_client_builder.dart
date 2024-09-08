import 'package:flutter/material.dart';
import 'package:lan_sharing/lan_sharing.dart';

class LanClientBuilder extends StatefulWidget {
  const LanClientBuilder({
    super.key,
    required this.lanClient,
    required this.builder,
  });

  final LanClient lanClient;
  final Widget Function(BuildContext context, ClientSocketState state) builder;

  @override
  State<LanClientBuilder> createState() => _LanClientBuilderState();
}

class _LanClientBuilderState extends State<LanClientBuilder> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ClientSocketState>(
      stream: widget.lanClient.stateStream,
      builder: (context, snapshot) {
        final state = snapshot.data ?? ClientSocketState.disconnected('');
        return widget.builder(context, state);
      },
    );
  }
}
