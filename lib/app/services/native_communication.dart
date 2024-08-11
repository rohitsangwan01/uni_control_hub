import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:uni_control_hub/app/data/linux_usb_hotplug.dart';
import 'package:uni_control_hub/app/data/logger.dart';
import 'package:uni_control_hub/app/models/usb_device.dart';

class NativeChannelService {
  static NativeChannelService get to => GetIt.instance<NativeChannelService>();

  late final _linuxHotplug = LinuxUsbHotplug();
  final _channel = const MethodChannel('@uni_control_hub/native_channel');
  final _messageConnector = const BasicMessageChannel(
    "@uni_control_hub/message_connector",
    StandardMessageCodec(),
  );

  // Listen to usb device connection/disconnection events
  Function(List<UsbDevice> usbDevice, bool? connected)? usbDeviceHandler;

  Future<NativeChannelService> init() async {
    _messageConnector.setMessageHandler(_handleMessage);
    return this;
  }

  void dispose() {
    _messageConnector.setMessageHandler(null);
    stopUsbDetection();
  }

  Future<void> _handleMessage(dynamic message) async {
    if (message is! Map) return;
    Map<String, dynamic> data = Map<String, dynamic>.from(message);
    String event = data['event'];
    if (event == 'device_update') {
      usbDeviceHandler?.call(
        List<UsbDevice>.from(
          data["devices"]?.map((e) => UsbDevice.fromJson(e)).toList() ?? [],
        ),
        data["connected"] ?? false,
      );
    } else {
      logDebug("UnhandledEvent: $message");
    }
  }

  Future<bool> haveMacAccessibilityPermission() async {
    return await _channel.invokeMethod<bool>('haveAccessibilityPermission') ??
        false;
  }

  Future<bool> requestMacAccessibilityPermission() async {
    return await _channel
            .invokeMethod<bool>('requestAccessibilityPermission') ??
        false;
  }

  Future<void> startUsbDetection() async {
    if (Platform.isMacOS) {
      return _channel.invokeMethod('startUsbDetection');
    } else if (Platform.isLinux) {
      _linuxHotplug.startUsbDetection(() {
        usbDeviceHandler?.call([], null);
      });
    }
  }

  Future<void> stopUsbDetection() async {
    if (Platform.isMacOS) {
      return _channel.invokeMethod('stopUsbDetection');
    } else if (Platform.isLinux) {
      _linuxHotplug.stopUsbDetection();
    }
  }
}
