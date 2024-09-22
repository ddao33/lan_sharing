import 'package:network_info_plus/network_info_plus.dart';

class IpHelper {
  static final info = NetworkInfo();

  static Future<String?> getLocalIpAddress() async {
    return await info.getWifiIP();
  }

  /// Subnet mask 255.255.255.0
  static List<String> getSubnetIps(String ipAddress) {
    List<String> result = [];

    List<String> octets = ipAddress.split('.');

    if (octets.length != 4) {
      throw Exception('Invalid IP address format');
    }

    for (int i = 0; i < 256; i++) {
      String newIP = '${octets[0]}.${octets[1]}.${octets[2]}.$i';
      result.add(newIP);
    }

    return result;
  }
}
