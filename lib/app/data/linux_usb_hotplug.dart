import 'dart:async';
import 'package:flutter/material.dart';
import 'package:udev/udev.dart';
import 'package:uni_control_hub/app/data/logger.dart';

class LinuxUsbHotplug {
  late final _udevContext = UdevContext();
  StreamSubscription? _devicesStreamSubscripton;
  bool _waitingLinuxEvents = false;

  Future<void> startUsbDetection(VoidCallback onDeviceUpdate) async {
    try {
      _devicesStreamSubscripton ??= _udevContext
          .monitorDevices(subsystems: ['usb']).listen((UdevDevice device) {
        if (_waitingLinuxEvents) return;
        _waitingLinuxEvents = true;
        Future.delayed(const Duration(seconds: 1)).then((_) {
          onDeviceUpdate();
          _waitingLinuxEvents = false;
        });
      });
    } catch (e) {
      logError('LinuxHotPlugFailed: $e');
    }
  }

  Future<void> stopUsbDetection() async {
    _devicesStreamSubscripton?.cancel();
    _devicesStreamSubscripton = null;
  }
}
