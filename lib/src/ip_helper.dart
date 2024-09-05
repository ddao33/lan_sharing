import 'dart:io';

class IpHelper {
  /// Get the local IP address and determine the subnet
  static Future<String?> getLocalIpAddress() async {
    List<NetworkInterface> interfaces = await NetworkInterface.list(
      type: InternetAddressType.IPv4,
      includeLoopback: false,
    );

    for (var interface in interfaces) {
      for (var address in interface.addresses) {
        if (!address.isLoopback) {
          return address.address;
        }
      }
    }
    return null;
  }

  /// Extract the subnet from the local IP address (e.g., if IP is 192.168.1.12, subnet is 192.168.1.)
  static String? extractSubnet(String ipAddress) {
    List<String> parts = ipAddress.split('.');
    if (parts.length == 4) {
      return '${parts[0]}.${parts[1]}.${parts[2]}.';
    }
    return null;
  }
}
