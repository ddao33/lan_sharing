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
## Setting up the Server
You can easily set up a server within your app. The server will listen for incoming client requests on a specified port.

```dart
import 'package:lan_sharing/lan_sharing.dart';

void startServer() async {
  final server = await LanServer.start(port: 8080);
  
  server.listen((request) {
    // Handle incoming requests and send responses
    final response = server.createResponse(
      statusCode: 200,
      body: 'Hello from the server!',
    );
    request.respond(response);
  });
}
Connecting as a Client
A client can be used to hit the server and retrieve data.

dart
```dart
import 'package:lan_sharing/lan_sharing.dart';

void connectToServer() async {
  final client = LanClient(host: '192.168.0.10', port: 8080);
  
  final response = await client.get('/'); // Make a GET request
  print('Response: ${response.body}');
}
Sending Data Between Devices
You can send different types of data, including JSON, plain text, and files.

```dart
import 'package:lan_sharing/lan_sharing.dart';

void sendData() async {
  final client = LanClient(host: '192.168.0.10', port: 8080);
  
  final response = await client.post('/data', body: {'key': 'value'}); // POST request
  print('Response: ${response.body}');
}
Stopping the Server
When you no longer need the server, you can stop it:

```dart
server.stop();
```

# Contributions

Feel free to contribute to this package! Please submit a pull request or file an issue for any improvements or bug fixes.

# License
This package is distributed under the MIT License. See the LICENSE file for more information.







