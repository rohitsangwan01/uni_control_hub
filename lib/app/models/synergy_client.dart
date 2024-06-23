import 'dart:convert';

class SynergyClient {
  String clientName;
  String serverAddress;
  int serverPort;

  SynergyClient({
    required this.clientName,
    required this.serverAddress,
    required this.serverPort,
  });

  factory SynergyClient.fromJson(Map<String, dynamic> json) {
    return SynergyClient(
      clientName: json['clientName'] ?? 'UniControlHub',
      serverAddress: json['serverAddress'],
      serverPort: json['serverPort'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'clientName': clientName,
      'serverAddress': serverAddress,
      'serverPort': serverPort,
    };
  }

  String toJsonString() => json.encode(toJson());

  factory SynergyClient.fromJsonString(String jsonString) =>
      SynergyClient.fromJson(json.decode(jsonString));
}
