enum ClientSocketStatus { disconnected, connecting, connected }

class ClientSocketState {
  final String? message;
  final ClientSocketStatus state;
  ClientSocketState({required this.message, required this.state});

  factory ClientSocketState.disconnected(String message) => ClientSocketState(
        message: message,
        state: ClientSocketStatus.disconnected,
      );

  factory ClientSocketState.connecting() => ClientSocketState(
        message: null,
        state: ClientSocketStatus.connecting,
      );

  factory ClientSocketState.connected() => ClientSocketState(
        message: null,
        state: ClientSocketStatus.connected,
      );

  @override
  int get hashCode => message.hashCode ^ state.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is ClientSocketState &&
        other.message == message &&
        other.state == state;
  }
}
