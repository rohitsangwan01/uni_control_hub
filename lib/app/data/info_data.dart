String get clientInfoText => '''
List of connected devices will be available here, There are two types of connections:

### Bluetooth: 
> Connect to the server from the bluetooth settings of your mobile, Bluetooth toggle must be enabled.

### USB/ADB: 
> Connect to the server by just plugging in the USB cable to your device, or by using UHID mode ( Switch from settings ) connect with ADB

Bluetooth connection is supported by mostly **IOS** devices, while USB connection is supported by **Android** devices only.

### Note:
In IOS devices, you need to enable **AssistiveTouch**, only then mouse pointer will be visible.
IOS devices will automatically become visible in the list of connected devices, after connecting via bluetooth,

Whereas After connect/disconnect usb devices, you need to refresh the list of connected devices manually by clicking on the refresh button.
''';

String get serverInfoText => '''
Server is a core part of the application, it is responsible for managing the connected devices and their interactions. so it must be enabled before connecting any device.

### Server Status:
Server can be started/stopped by clicking on the toggle button, internally it uses [Synergy](https://github.com/symless/synergy-core) server binaries to manage the connected devices.

### Connect via Synergy:

To connect to a synergy or barrier server, disable *Use default server* from settings, and provide the server IP address and port number in the respective fields.
''';

String get connectButtonInfoText => '''
Connect to the server via bluetooth, it is mainly used for IOS devices, as they don't support USB connection.

### Steps to connect:

1. Make sure bluetooth is enabled on your device, and enable this toggle button.
2. Open bluetooth settings in your mobile and search for the server in the list of available devices.
3. Click on the server name to connect.
4. After successful connection, you will see the server name in the list of connected devices.
5. On IOS devices, you need to enable **AssistiveTouch** to see the mouse pointer.


To easily toggle **AssistiveTouch** on **IOS** devices, you can use [this](https://www.icloud.com/shortcuts/a3cb85e77744445593665a229bbba440) shortcut

Bluetooth connection is not stable on **Android** yet, so if you want to use android device only, you can disable this feature.
''';

String get androidConnectionModeInfo => '''
Android devices can be connected either with **AOA** or with **UHID**

### AOA

This mode simulates a physical HID keyboard and Mouse using the [AOAv2](https://source.android.com/devices/accessories/aoa2#hid-support) protocol.

it works at the USB level directly (so it only works over USB).

Note: On Windows, AOA mode will close ADB connection

### UHID

This mode simulates a physical HID keyboard and Mouse using the [UHID](https://kernel.org/doc/Documentation/hid/uhid.txt) kernel module on the device.
One drawback is that it may not work on old Android versions due to permission errors.
This mode requires ADB, and can also work over wireless ADB

Note: Both devices must be under same network
''';

String get lockMouseTileInfo => '''
Assign a hotkey to confine the mouse cursor within the bounds of a specific device. 
Once locked, the mouse will only move relative to that device's screen. 
Pressing the hotkey again will release the lock, allowing the mouse to move freely between devices.
''';
