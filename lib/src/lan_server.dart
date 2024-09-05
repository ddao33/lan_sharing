import 'dart:io';
import 'dart:async';

import 'package:lan_sharing/src/model/client_message.dart';
import 'package:network_info_plus/network_info_plus.dart';

enum ServerState { stopped, starting, running, stopping }

class LanServer {
  int port;
  ServerSocket? _serverSocket;

  String? _ipAddress;
  String? get ipAddress => _ipAddress;

  final Map<String, Function(Socket, Map<String, dynamic>)> _endpoints = {};
  final StreamController<ServerState> _stateController =
      StreamController<ServerState>.broadcast();
  final StreamController<ClientMessage> _incomingDataController =
      StreamController<ClientMessage>.broadcast();

  // Change the set to a StreamController
  final StreamController<Set<String>> _connectedClientsController =
      StreamController<Set<String>>.broadcast();
  final Set<String> _connectedClients = {};

  static final LanServer _instance = LanServer._internal(3000);

  factory LanServer({required int port}) {
    _instance.port = port;
    return _instance;
  }

  LanServer._internal(this.port) {
    _stateController.add(ServerState.stopped);
    _connectedClientsController.add(_connectedClients);
  }

  Stream<ServerState> get stateStream => _stateController.stream;
  Stream<ClientMessage> get incomingDataStream =>
      _incomingDataController.stream;

  // Change the getter to return a Stream
  Stream<Set<String>> get connectedClientsStream =>
      _connectedClientsController.stream;

  void addEndpoint(
      String endpoint, Function(Socket, Map<String, dynamic>) handler) {
    _endpoints[endpoint] = handler;
  }

  Future<void> start() async {
    if (_serverSocket != null) {
      print('Server is already running');
      return;
    }

    _stateController.add(ServerState.starting);

    try {
      // Get the actual IP address
      final info = NetworkInfo();
      _ipAddress = await info.getWifiIP();

      if (_ipAddress != null) {
        _serverSocket = await ServerSocket.bind(_ipAddress!, port);
        _stateController.add(ServerState.running);
        print('Server started on $_ipAddress:$port');

        // Handle client connections
        _serverSocket!.listen(
          _handleClient,
          onError: (error) {
            print('Server socket error: $error');
            stop();
          },
          onDone: () {
            print('Server socket closed');
            stop();
          },
        );
      } else {
        throw Exception('Failed to get device IP address');
      }
    } catch (e) {
      print('Error starting server: $e');
      _stateController.add(ServerState.stopped);
      _serverSocket = null;
    }
  }

  void _handleClient(Socket client) {
    String clientIp = client.remoteAddress.address;
    int clientPort = client.remotePort;
    print('Client connected: $clientIp:$clientPort');

    // Add client IP to the set of connected clients and emit the updated set
    _connectedClients.add(clientIp);
    _connectedClientsController.add(Set.from(_connectedClients));

    client.listen(
      (data) {
        try {
          ClientMessage message =
              ClientMessage.fromJson(String.fromCharCodes(data));
          _incomingDataController.add(message);

          if (_endpoints.containsKey(message.endpoint)) {
            _endpoints[message.endpoint]!(client, message.data);
          } else {
            print('No endpoint found for message: $message');
          }
        } catch (e) {
          print('Error parsing message: $e');
        }
      },
      onError: (error) {
        print('Error from client $clientIp: $error');
        client.close();
        // Remove client IP from the set of connected clients and emit the updated set
        _connectedClients.remove(clientIp);
        _connectedClientsController.add(Set.from(_connectedClients));
      },
      onDone: () {
        print('Client disconnected: $clientIp');
        client.close();
        // Remove client IP from the set of connected clients and emit the updated set
        _connectedClients.remove(clientIp);
        _connectedClientsController.add(Set.from(_connectedClients));
      },
    );
  }

  void stop() {
    if (_serverSocket == null) {
      print('Server is not running');
      return;
    }

    _stateController.add(ServerState.stopping);
    _serverSocket?.close();
    _serverSocket = null;
    _stateController.add(ServerState.stopped);
    // Clear the set of connected clients and emit the empty set
    _connectedClients.clear();
    _connectedClientsController.add(Set<String>());
    print('Server stopped');
  }

  void dispose() {
    _stateController.close();
    _incomingDataController.close();
    _connectedClientsController.close();
  }
}
