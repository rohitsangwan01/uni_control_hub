import 'package:uni_control_hub/app/data/app_data.dart';

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
      clientName: json['clientName'] ?? AppData.appName,
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
}
