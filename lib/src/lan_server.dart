import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'package:lan_sharing/src/model/client_message.dart';
import 'package:lan_sharing/src/utils/dicovery_service.dart';
import 'package:network_info_plus/network_info_plus.dart';

enum LanServerState { stopped, starting, running, stopping }

class LanServer {
  ServerSocket? _serverSocket;
  String? _ipAddress;
  final Map<String, Function(Socket, Map<String, dynamic>)> _endpoints = {};
  final StreamController<ClientMessage> _incomingDataController =
      StreamController<ClientMessage>.broadcast();
  final StreamController<Set<String>> _connectedClientsController =
      StreamController<Set<String>>.broadcast();
  final Set<String> _connectedClients = {};
  LanServerState _currentState = LanServerState.stopped;

  LanServer();

  String? get ipAddress => _ipAddress;

  Stream<ClientMessage> get incomingDataStream =>
      _incomingDataController.stream;

  Stream<Set<String>> get connectedClientsStream =>
      _connectedClientsController.stream;

  void addEndpoint(
      String endpoint, Function(Socket, Map<String, dynamic>) handler) {
    _endpoints[endpoint] = handler;
  }

  LanServerState get currentState => _currentState;

  Future<void> start({int port = lanServerDefaultPort}) async {
    if (_serverSocket != null) {
      return;
    }

    _updateState(LanServerState.starting);

    try {
      final info = NetworkInfo();
      _ipAddress = await info.getWifiIP();

      if (_ipAddress != null) {
        _serverSocket = await ServerSocket.bind(_ipAddress!, port);
        _updateState(LanServerState.running);

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
      _updateState(LanServerState.stopped);
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
          ClientMessage message = ClientMessage.fromJson(utf8.decode(data));
          _incomingDataController.add(message);

          if (_endpoints.containsKey(message.endpoint)) {
            _endpoints[message.endpoint]!(client, message.data);
          }
        } catch (e) {
          // Skip the message if it's not a valid JSON
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

    _updateState(LanServerState.stopping);
    _serverSocket?.close();
    _serverSocket = null;
    _updateState(LanServerState.stopped);
    _connectedClients.clear();
    _connectedClientsController.add({});
  }

  void _updateState(LanServerState newState) {
    _currentState = newState;
  }

  void dispose() {
    stop();
    _incomingDataController.close();
    _connectedClientsController.close();
  }
}

extension LanServerExtension on Socket {
  void addUtf8String(String string) {
    add(utf8.encode(string));
  }
}
