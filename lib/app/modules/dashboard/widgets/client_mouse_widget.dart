import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:uni_control_hub/app/client/client.dart';
import 'package:uni_control_hub/app/data/extensions.dart';
import 'package:uni_control_hub/app/services/storage_service.dart';

class ClientMouseWidget extends StatefulWidget {
  final Client client;

  const ClientMouseWidget({
    super.key,
    required this.client,
  });

  @override
  State<ClientMouseWidget> createState() => _ClientMouseWidgetState();
}

class _ClientMouseWidgetState extends State<ClientMouseWidget> {
  final TextEditingController widthController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey();

  late Size clientShape = widget.client.screen.getShape().toSize();
  Size get appShape => MediaQuery.sizeOf(context);
  double get scaleX => min(500, appShape.width) / clientShape.width;
  double get scaleY => min(600, appShape.height) / clientShape.height;
  double get scale => (scaleX < scaleY ? scaleX : scaleY) - 0.005;
  Size get scaledClientShape =>
      Size(clientShape.width * scale, clientShape.height * scale);

  @override
  void initState() {
    widthController.text = clientShape.width.toString();
    heightController.text = clientShape.height.toString();
    super.initState();
  }

  void updateClientSize() {
    if (!_formKey.currentState!.validate()) return;
    final width = double.tryParse(widthController.text);
    final height = double.tryParse(heightController.text);
    Size size = Size(
      width ?? clientShape.width,
      height ?? clientShape.height,
    );
    StorageService.to.clientDefaultSize = size;
    clientShape = size;
    widget.client.reConnectClient();
    // Restart server
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.client.id),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: SizedBox(
            width: 500,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                const Text("Client's screen size from server's POV"),
                const SizedBox(height: 6),
                Watch((context) {
                  var mouseMovement = widget.client.mouseMovement.value;
                  double scaledMouseX = mouseMovement.$1.toDouble() * scale;
                  double scaledMouseY = mouseMovement.$2.toDouble() * scale;
                  return Column(
                    children: [
                      SizedBox(
                        width: scaledClientShape.width,
                        height: scaledClientShape.height,
                        child: Stack(
                          children: [
                            Container(
                              color:
                                  Theme.of(context).colorScheme.inversePrimary,
                              width: scaledClientShape.width,
                              height: scaledClientShape.height,
                            ),
                            Positioned(
                              left: scaledMouseX,
                              top: scaledMouseY,
                              child: Icon(
                                Icons.circle,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Client Absolute Movements: x: ${mouseMovement.$1}, y: ${mouseMovement.$2}",
                      ),
                    ],
                  );
                }),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 20,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: widthController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9]'))
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Width is required";
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                              labelText: "Width",
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: heightController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9]'))
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Height is required";
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                              labelText: "Height",
                              border: OutlineInputBorder(),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.sizeOf(context).width * 0.9,
                  child: ElevatedButton(
                    onPressed: updateClientSize,
                    child: const Text("Update Client Size"),
                  ),
                ),
                const SizedBox(height: 10),
                
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "Mouse moves with relative position on client, whereas server produces absolute mouse movements, "
                        "Hence we expect client to be of specific size, so that we can move mouse in that size freely",
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
