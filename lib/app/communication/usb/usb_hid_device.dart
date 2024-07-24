import 'dart:ffi';

import 'package:uni_control_hub/app/client/client.dart';
import 'package:uni_control_hub/app/models/usb_device.dart';
import 'package:uni_control_hub/generated/generated_bindings.dart';
import 'package:ffi/ffi.dart' as ffi;

/// [UsbHidDevice] is a wrapper class for USB HID devices
/// to interact with USB HID devices, it provides methods to register, unregister, send HID events
/// and load device description
class UsbHidDevice {
  final NativeLibrary _libusb;
  UsbDevice usbDevice;
  UsbHidDevice(this._libusb, this.usbDevice);

  Pointer<libusb_device_handle>? _devHandle;
  final int _defaultTimeOut = 1000;
  final int _aoaRegisterHid = 54;
  final int _aoaUnregisterHid = 55;
  final int _aoaSetHidReportDesc = 56;
  final int _aoaSendHidEvent = 57;
  final int _libUsbEndpointOut = libusb_endpoint_direction.LIBUSB_ENDPOINT_OUT;
  final int _libUsbRequestTypeVendor =
      libusb_request_type.LIBUSB_REQUEST_TYPE_VENDOR;
  Client? client;
  bool isOpened = false;

  String? manufacturer;
  String? product;
  String? serialNumber;

  String get deviceId {
    String prefix = product ?? manufacturer ?? usbDevice.vendorId.toString();
    String suffix = serialNumber ?? usbDevice.productId.toString();
    return "$prefix:$suffix";
  }

  void openDevice({
    bool loadDescription = false,
  }) {
    if (isOpened) return;
    var handle = _libusb.libusb_open_device_with_vid_pid(
        nullptr, usbDevice.vendorId, usbDevice.productId);
    if (handle == nullptr) {
      throw 'FAILED_TO_OPEN_DEVICE';
    }
    _devHandle = handle;
    if (loadDescription) _loadDescription(handle);
    isOpened = true;
  }

  void close() {
    if (_devHandle != null) {
      _libusb.libusb_close(_devHandle!);
      _devHandle = null;
      isOpened = false;
    }
  }

  void registerHid(int descriptorSize) {
    if (_devHandle == null) return;
    int requestType = _libUsbEndpointOut | _libUsbRequestTypeVendor;
    int request = _aoaRegisterHid;
    int value = 0;
    int index = descriptorSize;
    final Pointer<UnsignedChar> buffer = ffi.calloc<UnsignedChar>(0);
    int length = 0;
    int timeout = _defaultTimeOut;
    int r = _libusb.libusb_control_transfer(
      _devHandle!,
      requestType,
      request,
      value,
      index,
      buffer,
      length,
      timeout,
    );
    if (r < 0) throw _errorMessage(r);
  }

  void unregisterHID() {
    if (_devHandle == null) return;

    int requestType = _libUsbEndpointOut | _libUsbRequestTypeVendor;
    int request = _aoaUnregisterHid;
    int value = 0;
    int index = 0;
    final Pointer<UnsignedChar> buffer = ffi.calloc<UnsignedChar>(0);
    int length = 0;
    int timeout = _defaultTimeOut;
    int r = _libusb.libusb_control_transfer(
      _devHandle!,
      requestType,
      request,
      value,
      index,
      buffer,
      length,
      timeout,
    );
    if (r < 0) throw _errorMessage(r);
  }

  Future<void> sendHidDescriptor(List<int> descriptor, int size) async {
    if (_devHandle == null) return;

    int maxPacketSize = usbDevice.maxPacketSize;
    int requestType = _libUsbEndpointOut | _libUsbRequestTypeVendor;
    int request = _aoaSetHidReportDesc;
    int value = 0;
    final Pointer<UnsignedChar> buffer = ffi.calloc<UnsignedChar>(size);
    for (int i = 0; i < size; i++) {
      buffer[i] = descriptor[i];
    }
    int timeout = _defaultTimeOut;
    int offset = 0;
    while (offset < size) {
      int packetLength = size - offset;
      if (packetLength > maxPacketSize) {
        packetLength = maxPacketSize;
      }
      int r = _libusb.libusb_control_transfer(
        _devHandle!,
        requestType,
        request,
        value,
        offset,
        buffer + (offset),
        packetLength,
        timeout,
      );
      offset += packetLength;
      if (r < 0) throw _errorMessage(r);
    }
    ffi.calloc.free(buffer);
    await Future.delayed(const Duration(milliseconds: 500));
  }

  void sendHidEvent(List<int> event) {
    if (_devHandle == null) return;

    int size = event.length;
    int requestType = _libUsbEndpointOut | _libUsbRequestTypeVendor;
    int request = _aoaSendHidEvent;
    int value = 0;
    int index = 0;
    final Pointer<UnsignedChar> buffer = ffi.calloc<UnsignedChar>(size);
    for (int i = 0; i < size; i++) {
      buffer[i] = event[i];
    }
    int length = size;
    int timeout = _defaultTimeOut;
    int r = _libusb.libusb_control_transfer(
      _devHandle!,
      requestType,
      request,
      value,
      index,
      buffer,
      length,
      timeout,
    );
    if (r < 0) throw _errorMessage(r);
  }

  void _loadDescription(Pointer<libusb_device_handle> handle) {
    var descPtr = ffi.calloc<libusb_device_descriptor>();
    try {
      var device = _libusb.libusb_get_device(handle);
      if (device != nullptr) {
        var getDesc = _libusb.libusb_get_device_descriptor(device, descPtr) ==
            libusb_error.LIBUSB_SUCCESS;
        if (getDesc) {
          if (descPtr.ref.iManufacturer > 0) {
            manufacturer =
                _getStringDescriptorASCII(handle, descPtr.ref.iManufacturer);
          }
          if (descPtr.ref.iProduct > 0) {
            product = _getStringDescriptorASCII(handle, descPtr.ref.iProduct);
          }
          if (descPtr.ref.iSerialNumber > 0) {
            serialNumber =
                _getStringDescriptorASCII(handle, descPtr.ref.iSerialNumber);
          }
        }
      }
    } finally {
      ffi.calloc.free(descPtr);
    }
  }

  String? _getStringDescriptorASCII(
      Pointer<libusb_device_handle> handle, int descIndex) {
    String? result;
    Pointer<ffi.Utf8> string = ffi.calloc<Uint8>(256).cast();
    try {
      var ret = _libusb.libusb_get_string_descriptor_ascii(
          handle, descIndex, string.cast(), 256);
      if (ret > 0) {
        result = string.toDartString();
      }
    } finally {
      ffi.calloc.free(string);
    }
    return result;
  }

  String _errorMessage(int result) {
    Pointer<Char> msg = _libusb.libusb_error_name(result);
    return msg.cast<ffi.Utf8>().toDartString();
  }

  @override
  String toString() {
    return usbDevice.toString();
  }
}

/// [LibUsbDesktop] is a wrapper class for libusb library
/// to interact with USB devices, it provides methods to initialize libusb and list USB devices
class LibUsbDesktop {
  final NativeLibrary _libusb;
  LibUsbDesktop(this._libusb);

  bool init() => _libusb.libusb_init(nullptr) == libusb_error.LIBUSB_SUCCESS;

  void exit() => _libusb.libusb_exit(nullptr);

  List<UsbDevice> getDeviceList() {
    var deviceListPtr = ffi.calloc<Pointer<Pointer<libusb_device>>>();
    try {
      var count = _libusb.libusb_get_device_list(nullptr, deviceListPtr);
      if (count < 0) return [];
      try {
        return _iterateDevice(deviceListPtr.value).toList();
      } finally {
        _libusb.libusb_free_device_list(deviceListPtr.value, 1);
      }
    } finally {
      ffi.calloc.free(deviceListPtr);
    }
  }

  Iterable<UsbDevice> _iterateDevice(
    Pointer<Pointer<libusb_device>> deviceList,
  ) sync* {
    var descPtr = ffi.calloc<libusb_device_descriptor>();
    for (var i = 0; deviceList[i] != nullptr; i++) {
      var dev = deviceList[i];
      var addr = _libusb.libusb_get_device_address(dev);
      var getDesc = _libusb.libusb_get_device_descriptor(dev, descPtr) ==
          libusb_error.LIBUSB_SUCCESS;
      yield UsbDevice(
        identifier: addr.toString(),
        vendorId: getDesc ? descPtr.ref.idVendor : 0,
        productId: getDesc ? descPtr.ref.idProduct : 0,
        configurationCount: getDesc ? descPtr.ref.bNumConfigurations : 0,
        maxPacketSize: getDesc ? descPtr.ref.bMaxPacketSize0 : 0,
      );
    }
    ffi.calloc.free(descPtr);
  }
}
