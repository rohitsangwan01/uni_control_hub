import 'dart:math';

import 'package:flutter/material.dart';

import 'package:lottie/lottie.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:uni_control_hub/app/services/app_service.dart';
import 'package:uni_control_hub/app/services/communication_service.dart';
import 'package:uni_control_hub/app/data/info_data.dart';
import 'package:uni_control_hub/app/data/dialog_handler.dart';
import 'package:uni_control_hub/app/modules/dashboard/widgets/synergy_server_client_tile.dart';
import 'package:uni_control_hub/app/modules/dashboard/widgets/app_drawer.dart';
import 'package:uni_control_hub/app/modules/dashboard/widgets/ble_advertise_state_tile.dart';
import 'package:uni_control_hub/app/modules/dashboard/widgets/client_widget.dart';
import 'package:uni_control_hub/app/modules/dashboard/widgets/server_state_tile.dart';
import 'package:uni_control_hub/app/data/app_data.dart';
import 'package:uni_control_hub/app/services/client_service.dart';
import 'package:uni_control_hub/app/services/storage_service.dart';
import 'package:uni_control_hub/app/services/synergy_service.dart';
import 'package:window_manager/window_manager.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> with WindowListener {
  late final CommunicationService communicationService =
      CommunicationService.to;
  late final SynergyService synergyService = SynergyService.to;
  late final AppService _appService = AppService.to;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    _setup();
  }

  void _setup() async {
    StorageService storageService = StorageService.to;
    if (storageService.autoStartServer && storageService.useInternalServer) {
      await synergyService.startServer(context);
      await Future.delayed(const Duration(seconds: 1));
    }
    ClientService.to.refreshClients();
    await windowManager.setPreventClose(true);
    setState(() {});
  }

  @override
  void onWindowClose() async {
    if (!await windowManager.isPreventClose()) return;
    showDialog(
      // ignore: use_build_context_synchronously
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog.adaptive(
          title: const Text('Do you really want to quit?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await AppService.to.disposeResources();
                await windowManager.destroy();
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Uni Control Hub'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      drawer: const AppDrawer(),
      body: SizedBox(
        width: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 5),
              LottieBuilder.asset(
                AppAssets.mouseAnim,
                height: 140,
              ),
              const SizedBox(height: 20),
              const Text(
                "Control your devices with same mouse and keyboard",
                style: TextStyle(color: Colors.grey),
              ),
              SizedBox(
                width: min(450, MediaQuery.sizeOf(context).width),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Watch((_) => _appService.userInternalServer.value
                        ? const ServerStateTile()
                        : const SynergyServerClientTile()),
                    Watch((_) => _appService.enableBluetoothMode.value
                        ? const BleAdvertiseStateTile()
                        : const SizedBox.shrink()),
                    const SizedBox(height: 20),
                    const _ClientTitleWidget(),
                    const _CursorLockedWidget(),
                    const SizedBox(height: 10),
                    const _ClientsListWidget(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CursorLockedWidget extends StatelessWidget {
  const _CursorLockedWidget();

  @override
  Widget build(BuildContext context) {
    final SynergyService synergyService = SynergyService.to;
    return Watch((_) => synergyService.cursorLocked.value
        ? Row(
            children: [
              const SizedBox(width: 10),
              Text(
                'Cursor locked to current Screen',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(width: 10),
              const Icon(
                Icons.lock,
                size: 14,
              ),
            ],
          )
        : const SizedBox.shrink());
  }
}

class _ClientsListWidget extends StatelessWidget {
  const _ClientsListWidget();

  @override
  Widget build(BuildContext context) {
    final communicationService = CommunicationService.to;
    return Watch((_) {
      if (communicationService.devices.isEmpty) {
        return const _NoClientWidget();
      }
      return Column(
        children: communicationService.devices
            .map((element) => ClientWidget(client: element))
            .toList(),
      );
    });
  }
}

class _NoClientWidget extends StatelessWidget {
  const _NoClientWidget();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: const Text(
          "No client connected yet",
          style: TextStyle(color: Colors.grey),
        ),
        subtitle: Text(
          "Connect your device either with bluetooth or usb and refresh",
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Colors.grey,
              ),
        ),
      ),
    );
  }
}

class _ClientTitleWidget extends StatelessWidget {
  const _ClientTitleWidget();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                "Clients",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              IconButton(
                onPressed: () {
                  DialogHandler.showInfoDialog(
                    context: context,
                    title: "Clients",
                    text: clientInfoText,
                  );
                },
                icon: const Icon(
                  Icons.info_outline,
                  size: 18,
                ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  ClientService.to.refreshClients();
                },
                icon: const Icon(Icons.refresh, size: 18),
              ),
            ],
          )
        ],
      ),
    );
  }
}
