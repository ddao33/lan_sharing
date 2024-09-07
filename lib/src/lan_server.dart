import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'package:lan_sharing/src/model/client_message.dart';
import 'package:network_info_plus/network_info_plus.dart';

enum LanServerState { stopped, starting, running, stopping }

class LanServer {
  ServerSocket? _serverSocket;
  String? _ipAddress;
  final Map<String, Function(Socket, Map<String, dynamic>)> _endpoints = {};
  final StreamController<LanServerState> _stateController =
      StreamController<LanServerState>.broadcast();
  final StreamController<ClientMessage> _incomingDataController =
      StreamController<ClientMessage>.broadcast();
  final StreamController<Set<String>> _connectedClientsController =
      StreamController<Set<String>>.broadcast();
  final Set<String> _connectedClients = {};

  static final LanServer _instance = LanServer._internal();

  factory LanServer() {
    return _instance;
  }

  LanServer._internal() {
    _stateController.add(LanServerState.stopped);
    _connectedClientsController.add(_connectedClients);
  }

  String? get ipAddress => _ipAddress;

  Stream<LanServerState> get stateStream => _stateController.stream;

  Stream<ClientMessage> get incomingDataStream =>
      _incomingDataController.stream;

  Stream<Set<String>> get connectedClientsStream =>
      _connectedClientsController.stream;

  void addEndpoint(
      String endpoint, Function(Socket, Map<String, dynamic>) handler) {
    _endpoints[endpoint] = handler;
  }

  Future<void> start({required int port}) async {
    if (_serverSocket != null) {
      throw StateError('Server is already running');
    }

    _stateController.add(LanServerState.starting);

    try {
      final info = NetworkInfo();
      _ipAddress = await info.getWifiIP();

      if (_ipAddress != null) {
        _serverSocket = await ServerSocket.bind(_ipAddress!, port);
        _stateController.add(LanServerState.running);

        _serverSocket!.listen(
          _handleClient,
          onError: (error) {
            stop();
          },
          onDone: () {
            stop();
          },
        );
      } else {
        throw Exception('Failed to get device IP address');
      }
    } catch (e) {
      _stateController.add(LanServerState.stopped);
      _serverSocket = null;
      rethrow;
    }
  }

  void _handleClient(Socket client) {
    String clientIp = client.remoteAddress.address;
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
          }
        } catch (e) {
          // Consider using a logger instead of print
        }
      },
      onError: (error) {
        _removeClient(client, clientIp);
      },
      onDone: () {
        _removeClient(client, clientIp);
      },
    );
  }

  void _removeClient(Socket client, String clientIp) {
    client.close();
    _connectedClients.remove(clientIp);
    _connectedClientsController.add(Set.from(_connectedClients));
  }

  void stop() {
    if (_serverSocket == null) {
      return;
    }

    _stateController.add(LanServerState.stopping);
    _serverSocket?.close();
    _serverSocket = null;
    _stateController.add(LanServerState.stopped);
    _connectedClients.clear();
    _connectedClientsController.add({});
  }

  void dispose() {
    stop();
    _stateController.close();
    _incomingDataController.close();
    _connectedClientsController.close();
  }
}

extension LanServerExtension on Socket {
  void addUtf8String(String string) {
    add(utf8.encode(string));
  }
}
