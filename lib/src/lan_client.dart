import 'dart:io';
import 'dart:async';

import 'package:lan_sharing/src/client_message.dart';
import 'package:lan_sharing/src/ip_helper.dart';

enum ClientState { disconnected, connecting, connected }

class LanClient {
  final int port;
  final Duration timeout;
  final Function(String message) onMessage;
  Socket? socket;

  final StreamController<ClientState> _stateController =
      StreamController<ClientState>.broadcast();

  Stream<ClientState> get stateStream => _stateController.stream;

  LanClient({
    required this.port,
    this.timeout = const Duration(
      milliseconds: 900,
    ),
    required this.onMessage,
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

  /// Attempt to connect to a specific IP address
  Future<bool> tryConnect(String ipAddress) async {
    _stateController.add(ClientState.connecting);
    try {
      socket = await Socket.connect(ipAddress, port, timeout: timeout);
      socket?.listen((event) {
        onMessage(String.fromCharCodes(event));
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Automatically find the server by scanning the local subnet in parallel
  Future<String?> findServer() async {
    String? localIp = await IpHelper.getLocalIpAddress();
    if (localIp == null) {
      print('Unable to determine local IP address');
      return null;
    }

    String? subnet = IpHelper.extractSubnet(localIp);
    if (subnet == null) {
      print('Unable to determine subnet');
      return null;
    }

    print('Scanning network on subnet: $subnet');

    // Create a list of IP addresses to scan
    List<String> ipAddresses = List.generate(254, (i) => '$subnet${i + 1}');

    // Perform parallel connection attempts
    List<Future<bool>> connectionAttempts =
        ipAddresses.map((ip) => tryConnect(ip)).toList();

    // Wait for all connection attempts
    List<bool> results = await Future.wait(connectionAttempts);

    // Check which IP addresses were successful
    for (int i = 0; i < results.length; i++) {
      if (results[i]) {
        print('Connected to server at ${ipAddresses[i]}:$port');
        _stateController.add(ClientState.connected);
        return ipAddresses[i];
      }
    }

    print('Server not found on the network');
    _stateController.add(ClientState.disconnected);
    return null;
  }

  void dispose() {
    socket?.destroy();
    socket = null;
    _stateController.add(ClientState.disconnected);
  }
}
