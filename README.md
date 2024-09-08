# Lan Sharing 

Lan_sharing is a Flutter package that simplifies local area network (LAN) communication by allowing you to set up a server within your Flutter app and interact with it using a client. This package is useful for sharing data across devices connected to the same network without requiring external servers or internet connectivity.

# Features
- Server creation: Start a server within your Flutter app to handle requests from other clients.
- Client communication: Send requests to the server and receive responses, allowing for smooth data exchange.
- Cross-platform: Works on both Android and iOS devices connected to the same LAN.
- Customizable: Configure your server and client settings as per your app's needs.

# Installation
Add lan_sharing to your pubspec.yaml:

```yaml
dependencies:
  lan_sharing: latest_version
```

Then, run flutter pub get to install the package.

# Usage

## Setup Server 

```dart
import 'package:lan_sharing/lan_sharing.dart';

// Initialize the server
final server = LanServer()..start();
  

// Add an endpoint to the server
LanServer().addEndpoint('/test', (socket, data) {
  socket.addUtf8String('Hello THIS IS FROM TEST');
});

```

## Setup Client

```dart
import 'package:lan_sharing/lan_sharing.dart';

// Initialize the client
final client = LanClient();

// Try to find the server on the local network
await client.findServer();

// Send a message to the server
await client.sendMessage(endpoint: '/test', data: {'message': 'Hello Server!'});

```

# Contributions

Feel free to contribute to this package! Please submit a pull request or file an issue for any improvements or bug fixes.

# License
This package is distributed under the MIT License. See the LICENSE file for more information.







