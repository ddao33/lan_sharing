import 'dart:async';
import 'package:lan_sharing/src/utils/ip_helper.dart';

typedef TryFunction = Future<bool> Function(String ipAddress);

/// A utility function for discovering devices on a local area network (LAN).
///
/// This function attempts to connect to devices on the same subnet as the local machine
/// using a provided [TryFunction]. It checks all possible IP addresses
/// within the subnet and returns the first IP address that successfully connects.
/// Returns:
/// - A [Future<String?>] that resolves to the IP address of the discovered device,
///   or null if no device is found.
///
/// Throws:
/// - An [Exception] if it's unable to determine the local IP address or subnet.
///

Future<String?> discoverOnLan(TryFunction tryFunction) async {
  String? localIp = await IpHelper.getLocalIpAddress();
  if (localIp == null) {
    throw Exception('Unable to determine local IP address');
  }

  String? subnet = IpHelper.extractSubnet(localIp);
  if (subnet == null) {
    throw Exception('Unable to determine subnet');
  }

  List<String> ipAddresses = List.generate(254, (i) => '$subnet${i + 1}');

  List<Future<String?>> discoveryFutures = ipAddresses.map((ip) async {
    bool result = await tryFunction(ip);
    if (result) {
      return ip;
    }
    return null;
  }).toList();

  List<String?> results = await Future.wait(discoveryFutures);
  String? discoveredIp =
      results.firstWhere((ip) => ip != null, orElse: () => null);

  if (discoveredIp != null) {
    return discoveredIp;
  }

  return null;
}
