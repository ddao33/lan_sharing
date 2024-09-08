# Lan Sharing 

`lan_sharing` is a Flutter package that simplifies local area network communication by allowing you to set up a server within your Flutter app and interact with it using a client. This package is useful for sharing data across devices connected to the same network without requiring external servers or internet connectivity.

# Features
- Server creation: Start a server within your Flutter app to handle requests from other clients.

- Client communication: Send requests to the server and receive responses, allowing for smooth data exchange.

- Customizable: Configure your server and client settings as per your app's needs.

# Installation
Add lan_sharing to your pubspec.yaml:

```yaml
dependencies:
  lan_sharing: ^0.1.0
```

Then, run flutter pub get to install the package.

# Usage

## Setup Server 

```dart
import 'package:lan_sharing/lan_sharing.dart';

// Initialize the server
final server = LanServer()..start();
  

// Add an endpoint to the server which will be used by client
LanServer().addEndpoint('/test', (socket, data) {
  socket.addUtf8String('Hello THIS IS FROM TEST');
});
```

See example in example_server for more details. 

## Setup Client

```dart
import 'package:lan_sharing/lan_sharing.dart';

// Initialize the client and set up a callback to handle incoming data
final client = LanClient(
  onData: (data) {
    print(utf8.decode(data));
  },
);

// Try to find the server on the local network
await client.findServer();

// Send a message to the server
await client.sendMessage(endpoint: '/test', data: {});
```

# Contributions

Feel free to contribute to this package! Please submit a pull request or file an issue for any improvements or bug fixes.








