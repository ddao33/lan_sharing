import 'dart:convert';

class ClientMessage {
  final String endpoint;
  final Map<String, dynamic> data;

  ClientMessage({required this.endpoint, required this.data});

  String toJson() {
    return jsonEncode({'endpoint': endpoint, ...data});
  }

  static ClientMessage fromJson(String json) {
    Map<String, dynamic> map = jsonDecode(json);
    return ClientMessage(
      endpoint: map['endpoint'],
      data: map,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ClientMessage &&
        other.endpoint == endpoint &&
        _mapEquals(other.data, data);
  }

  @override
  int get hashCode => endpoint.hashCode ^ data.hashCode;

  bool _mapEquals(Map<String, dynamic> map1, Map<String, dynamic> map2) {
    if (map1.length != map2.length) return false;
    return map1.entries.every((entry) =>
        map2.containsKey(entry.key) && map2[entry.key] == entry.value);
  }
}
