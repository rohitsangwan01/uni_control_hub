import 'package:flutter/services.dart';

class NativeCommunication {
  static const _channel = MethodChannel('@uni_control_hub/native_channel');

  static Future<bool> haveMacAccessibilityPermission() async {
    return await _channel.invokeMethod<bool>('haveAccessibilityPermission') ??
        false;
  }

  static Future<bool> requestMacAccessibilityPermission() async {
    return await _channel
            .invokeMethod<bool>('requestAccessibilityPermission') ??
        false;
  }
}
