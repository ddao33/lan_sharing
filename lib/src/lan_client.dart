import 'dart:io';
import 'dart:async';
import 'dart:typed_data';

import 'package:lan_sharing/src/model/client_message.dart';
import 'package:lan_sharing/src/model/client_socket_response.dart';
import 'package:lan_sharing/src/utils/dicovery_service.dart';

class LanClient {
  final int port;
  final Duration timeout;
  final void Function(Uint8List data)? onData;
  Socket? socket;

  String? get serverIp => socket?.remoteAddress.address;

  final StreamController<ClientSocketState> _stateController =
      StreamController<ClientSocketState>.broadcast();

  Stream<ClientSocketState> get stateStream => _stateController.stream;

  LanClient({
    this.port = lanServerDefaultPort,
    this.timeout = const Duration(
      milliseconds: 900,
    ),
    required this.onData,
  }) {
    _stateController.add(ClientSocketState.disconnected(''));
  }

  Future<void> sendMessage({
    required String endpoint,
    required Map<String, dynamic> data,
  }) async {
    if (socket == null) {
      _stateController.add(ClientSocketState.disconnected(''));
      return;
    }
    try {
      final message = ClientMessage(endpoint: endpoint, data: data);
      final jsonMessage = message.toJson();
      final encodedMessage = jsonMessage.codeUnits;
      socket?.add(encodedMessage);
      _stateController.add(ClientSocketState.connected());
    } catch (e) {
      _stateController.add(ClientSocketState.disconnected(e.toString()));
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

  /// Find a server on the local network by broadcasting a discovery message and listening for responses.
  /// Returns the IP address of the server if found, otherwise returns null.
  Future<String?> findServer() async {
    _stateController.add(ClientSocketState.connecting());
    final serverIp = await discoverOnLan(tryConnect);
    if (serverIp != null) {
      _stateController.add(ClientSocketState.connected());
      return serverIp;
    }
    _stateController.add(ClientSocketState.disconnected(''));
    return null;
  }

  void dispose() {
    socket?.destroy();
    socket = null;
    _stateController.add(ClientSocketState.disconnected(''));
  }
}
