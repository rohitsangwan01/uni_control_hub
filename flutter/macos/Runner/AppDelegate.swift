import Cocoa
import FlutterMacOS
import Foundation
import IOKit.usb

@main
class AppDelegate: FlutterAppDelegate {
    private var notificationPort: IONotificationPortRef?
    private var isRunning = false
    private var newDevices: [USBDevice] = []
    private var newDevicesTimer: Timer?
    private var newDevicesIterator: io_iterator_t = IO_OBJECT_NULL
    private var removedDevices: [USBDevice] = []
    private var removedDevicesTimer: Timer?
    private var removedDevicesIterator: io_iterator_t = IO_OBJECT_NULL
    private var messageConnector: FlutterBasicMessageChannel?
    
    override func applicationDidFinishLaunching(_: Notification) {
        let controller: FlutterViewController = mainFlutterWindow?.contentViewController as! FlutterViewController
        let channel = FlutterMethodChannel(name: "@uni_control_hub/native_channel", binaryMessenger: controller.engine.binaryMessenger)
        messageConnector = FlutterBasicMessageChannel(name: "@uni_control_hub/message_connector", binaryMessenger: controller.engine.binaryMessenger)
        channel.setMethodCallHandler { (_ call: FlutterMethodCall, _ result: FlutterResult) in
            self.methodCallHandler(call, result)
        }
    }
    
    override func applicationShouldTerminateAfterLastWindowClosed(_: NSApplication) -> Bool {
        return true
    }

    func methodCallHandler(_ call: FlutterMethodCall, _ result: FlutterResult) {
        if call.method == "haveAccessibilityPermission" {
            result(isAppTrustedForAccessibility())
        } else if call.method == "requestAccessibilityPermission" {
            result(requestAccessibilityPermission())
        } else if call.method == "startUsbDetection" {
            startDetection()
            result(nil)
        } else if call.method == "stopUsbDetection" {
            stopDetection()
            result(nil)
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

    private func onDeviceUpdate(devices: [USBDevice], connected: Bool) {
        DispatchQueue.main.async {
            self.messageConnector?.sendMessage([
                "event": "device_update",
                "connected": connected,
                "devices": devices.map { it in
                    it.toJson()
                },
            ])
        }
    }

    private func onDetectorStatusChange(running: Bool) {
        isRunning = running
        DispatchQueue.main.async {
            self.messageConnector?.sendMessage([
                "event": "detector_status_change",
                "running": running,
            ])
        }
    }

    private func startDetection() {
        if isRunning {
            print("Already Tracking")
            return
        }
        notificationPort = IONotificationPortCreate(kIOMainPortDefault)

        let runLoopSource = IONotificationPortGetRunLoopSource(notificationPort).takeUnretainedValue()
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, CFRunLoopMode.defaultMode)

        let matchingDict = IOServiceMatching(kIOUSBDeviceClassName)

        let newDevicesCallbackClosure: IOServiceMatchingCallback = { context, iterator in
            let detector = Unmanaged<AppDelegate>.fromOpaque(context!).takeUnretainedValue()
            detector.processNewDevices(iterator: iterator)
        }

        let resultAddedDevices = IOServiceAddMatchingNotification(notificationPort,
                                                                  kIOMatchedNotification,
                                                                  matchingDict,
                                                                  newDevicesCallbackClosure,
                                                                  Unmanaged.passUnretained(self).toOpaque(),
                                                                  &newDevicesIterator)

        let removedDevicesCallbackClosure: IOServiceMatchingCallback = { context, iterator in
            let detector = Unmanaged<AppDelegate>.fromOpaque(context!).takeUnretainedValue()
            detector.processRemovedDevices(iterator: iterator)
        }

        let resultRemovedDevices = IOServiceAddMatchingNotification(notificationPort,
                                                                    kIOTerminatedNotification,
                                                                    matchingDict,
                                                                    removedDevicesCallbackClosure,
                                                                    Unmanaged.passUnretained(self).toOpaque(),
                                                                    &removedDevicesIterator)

        if resultAddedDevices == kIOReturnSuccess && resultRemovedDevices == kIOReturnSuccess {
            _ = unpackDevicesFromIterator(iterator: newDevicesIterator)
            _ = unpackDevicesFromIterator(iterator: removedDevicesIterator)
            onDetectorStatusChange(running: true)
        } else {
            stopDetection()
        }
    }

    private func stopDetection() {
        if let notificationPort = notificationPort {
            let runLoopSource = IONotificationPortGetRunLoopSource(notificationPort).takeUnretainedValue()
            CFRunLoopRemoveSource(CFRunLoopGetCurrent(), runLoopSource, CFRunLoopMode.defaultMode)
            IONotificationPortDestroy(notificationPort)
        }

        notificationPort = nil

        if newDevicesIterator != 0 {
            _ = unpackDevicesFromIterator(iterator: newDevicesIterator)
            IOObjectRelease(newDevicesIterator)
            newDevicesIterator = IO_OBJECT_NULL
        }

        if removedDevicesIterator != 0 {
            _ = unpackDevicesFromIterator(iterator: removedDevicesIterator)
            IOObjectRelease(removedDevicesIterator)
            removedDevicesIterator = IO_OBJECT_NULL
        }
        onDetectorStatusChange(running: false)
    }

    private func processNewDevices(iterator: io_iterator_t) {
        newDevicesTimer?.invalidate()
        newDevices.append(contentsOf: unpackDevicesFromIterator(iterator: iterator))
        newDevicesTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { [weak self] _ in
            guard let self else { return }
            self.onDeviceUpdate(devices: self.newDevices, connected: true)
            self.newDevices.removeAll()
        }
    }

    private func processRemovedDevices(iterator: io_iterator_t) {
        removedDevicesTimer?.invalidate()
        removedDevices.append(contentsOf: unpackDevicesFromIterator(iterator: iterator))
        removedDevicesTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { [weak self] _ in
            guard let self else { return }
            self.onDeviceUpdate(devices: self.removedDevices, connected: false)
            self.removedDevices.removeAll()
        }
    }

    private func unpackDevicesFromIterator(iterator: io_iterator_t) -> [USBDevice] {
        var devices = [USBDevice]()
        var device = IOIteratorNext(iterator)
        while device != 0 {
            var vendorID = 0
            var productID = 0
            var manufacturer = ""
            var product = ""
            if let vendorIDCF = IORegistryEntryCreateCFProperty(device, kUSBVendorID as CFString, kCFAllocatorDefault, 0) {
                vendorID = (vendorIDCF.takeRetainedValue() as? NSNumber)?.intValue ?? 0
            }
            if let productIDCF = IORegistryEntryCreateCFProperty(device, kUSBProductID as CFString, kCFAllocatorDefault, 0) {
                productID = (productIDCF.takeRetainedValue() as? NSNumber)?.intValue ?? 0
            }
            if let manufacturerCF = IORegistryEntryCreateCFProperty(device, kUSBVendorString as CFString, kCFAllocatorDefault, 0) {
                manufacturer = (manufacturerCF.takeRetainedValue() as? String) ?? ""
            }
            if let productCF = IORegistryEntryCreateCFProperty(device, kUSBProductString as CFString, kCFAllocatorDefault, 0) {
                product = (productCF.takeRetainedValue() as? String) ?? ""
            }
            let newDevice = USBDevice(vendorID: vendorID, productID: productID, manufacturer: manufacturer, product: product)
            devices.append(newDevice)
            IOObjectRelease(device)
            device = IOIteratorNext(iterator)
        }
        return devices
    }
}

struct USBDevice: Identifiable {
    var id: String { return "\(vendorID)-\(productID)" }
    var vendorID: Int
    var productID: Int
    var manufacturer: String
    var product: String

    func toJson() -> [String: Any] {
        return [
            "vendorId": vendorID,
            "productId": productID,
            "manufacturer": manufacturer,
            "product": product,
        ]
    }
}
