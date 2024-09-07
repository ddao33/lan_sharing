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

  String? get serverIp => socket?.remoteAddress.address;

  final StreamController<ClientState> _stateController =
      StreamController<ClientState>.broadcast();

  Stream<ClientState> get stateStream => _stateController.stream;

  LanClient({
    this.port = lanServerDefaultPort,
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
    _stateController.add(ClientState.connecting);
    final serverIp = await discoverOnLan(tryConnect);
    if (serverIp != null) {
      _stateController.add(ClientState.connected);
      return serverIp;
    }
    _stateController.add(ClientState.disconnected);
    return null;
  }

  void dispose() {
    socket?.destroy();
    socket = null;
    _stateController.add(ClientState.disconnected);
  }
}
