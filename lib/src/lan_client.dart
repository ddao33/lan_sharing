import 'dart:io';
import 'dart:async';
import 'dart:typed_data';

import 'package:lan_sharing/src/model/client_message.dart';
import 'package:lan_sharing/src/utils/dicovery_service.dart';

enum ClientState { disconnected, connecting, connected }

class LanClient {
  final int port;
  final Duration timeout;
  final void Function(Uint8List data)? onData;
  Socket? socket;

  final StreamController<ClientState> _stateController =
      StreamController<ClientState>.broadcast();

  Stream<ClientState> get stateStream => _stateController.stream;

  LanClient({
    required this.port,
    this.timeout = const Duration(
      milliseconds: 900,
    ),
    required this.onData,
  }) {
    _stateController.add(ClientState.disconnected);
  }

  Future<void> sendMessage({
    required String endpoint,
    required Map<String, dynamic> data,
  }) async {
    if (socket == null) {
      _stateController.add(ClientState.disconnected);
      return;
    }
    try {
      final message = ClientMessage(endpoint: endpoint, data: data);
      final jsonMessage = message.toJson();
      final encodedMessage = jsonMessage.codeUnits;
      socket?.add(encodedMessage);
      _stateController.add(ClientState.connected);
    } catch (e) {
      _stateController.add(ClientState.disconnected);
      print('Error sending message: $e');
    }
  }

  Future<bool> tryConnect(String ipAddress) async {
    try {
      socket = await Socket.connect(ipAddress, port, timeout: timeout);
      socket?.listen(onData);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<String?> findServer() async {
    return await discoverOnLan(tryConnect);
  }

  void dispose() {
    socket?.destroy();
    socket = null;
    _stateController.add(ClientState.disconnected);
  }
}
