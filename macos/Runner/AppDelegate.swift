import Cocoa
import FlutterMacOS

@NSApplicationMain
class AppDelegate: FlutterAppDelegate {
  override func applicationDidFinishLaunching(_: Notification) {
    let controller: FlutterViewController = mainFlutterWindow?.contentViewController as! FlutterViewController
    let channel = FlutterMethodChannel(name: "@uni_control_hub/native_channel", binaryMessenger: controller.engine.binaryMessenger)
    channel.setMethodCallHandler { (_ call: FlutterMethodCall, _ result: FlutterResult) in
      self.methodCallHandler(call, result)
    }
  }

  override func applicationShouldTerminateAfterLastWindowClosed(_: NSApplication) -> Bool {
    return true
  }

  func methodCallHandler(_ call: FlutterMethodCall, _ result: FlutterResult) {
    if call.method == "haveAccessibilityPermission" {
      // Check accessibility permission
      result(isAppTrustedForAccessibility())
    } else if call.method == "requestAccessibilityPermission" {
      // Ask for accessibility permission
      result(requestAccessibilityPermission())
    } else {
      result(FlutterMethodNotImplemented)
    }
  }

  func isAppTrustedForAccessibility() -> Bool {
    let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeRetainedValue() as NSString: true]
    let accessibilityEnabled = AXIsProcessTrustedWithOptions(options)

    return accessibilityEnabled
  }

  func requestAccessibilityPermission() -> Bool {
    let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeRetainedValue() as NSString: true]
    let accessEnabled = AXIsProcessTrustedWithOptions(options)
    return accessEnabled
  }
}
