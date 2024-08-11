class UsbDevice {
  final String identifier;
  final int vendorId;
  final int productId;
  final int configurationCount;
  final int maxPacketSize;

  UsbDevice({
    required this.identifier,
    required this.vendorId,
    required this.productId,
    required this.configurationCount,
    required this.maxPacketSize,
  });

  factory UsbDevice.fromJson(json) {
    return UsbDevice(
      identifier: json['product'] ?? "",
      vendorId: json["vendorId"] ?? 0,
      productId: json["productId"] ?? 0,
      configurationCount: -1,
      maxPacketSize: -1,
    );
  }

  String get uid => '$vendorId:$productId';

  @override
  String toString() {
    return 'UsbDevice{identifier: $identifier, vendorId: $vendorId, productId: $productId, configurationCount: $configurationCount, maxPacketSize: $maxPacketSize}';
  }
}
