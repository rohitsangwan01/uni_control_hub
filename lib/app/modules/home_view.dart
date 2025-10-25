import 'package:flutter/material.dart';
import 'package:uni_control_hub/app/rust/api/clients/client_ble.dart';
import 'package:uni_control_hub/app/rust/api/clients/client_usb.dart';
import 'package:uni_control_hub/app/rust/api/input_handler.dart';
import 'package:uni_control_hub/app/rust/api/rx_handlers.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final InputHandler inputHandler = InputHandler();
  late final (PositionVecU8Sender, PositionVecU8Receiver) positionStream;
  bool listening = false;

  @override
  initState() {
    super.initState();
    listenClients();
  }

  void listenClients() async {
    UsbClient usbClient = await UsbClient.newInstance();
    BleClient bleClient = await BleClient.newInstance();

    usbClient.watchDevices().listen((event) {
      debugPrint('Client Event: $event');
    });

    bleClient.watchDevices().listen((event) {
      debugPrint('Client Event: $event');
    });
  }

  void initStream() async {
    positionStream = await inputHandler.createPositionStream();
    listening = true;
    while (listening) {
      try {
        final position = await positionStream.$2.recv();
        debugPrint('Position: ${position.$1}, Data: ${position.$2}');
      } catch (_) {}
    }
  }

  void disposeStream() {
    listening = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Center(
        child: Column(
          spacing: 10,
          children: [
            Row(
              children: [
                ElevatedButton(
                    onPressed: () {
                      initStream();
                    },
                    child: const Text('Start Listening')),
                ElevatedButton(
                    onPressed: () {
                      disposeStream();
                    },
                    child: const Text('Stop Listening')),
              ],
            ),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    await inputHandler.run(positionStream: positionStream.$1);
                  },
                  child: const Text('Run Capture Request'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await inputHandler.stop();
                  },
                  child: const Text('Stop Capture Request'),
                ),
              ],
            ),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    await inputHandler.sendCaptureRequest(
                      request: CaptureRequest.create(Position.left),
                    );
                    debugPrint('Capture Request Sent');
                  },
                  child: const Text('Create Capture Request'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
