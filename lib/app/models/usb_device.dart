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

  String get uid => '$vendorId:$productId';

  @override
  String toString() {
    return 'UsbDevice{identifier: $identifier, vendorId: $vendorId, productId: $productId, configurationCount: $configurationCount, maxPacketSize: $maxPacketSize}';
  }
}
