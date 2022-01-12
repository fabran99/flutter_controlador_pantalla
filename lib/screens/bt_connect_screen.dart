import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../providers/bluetooth.dart';

class BTConnectScreen extends StatelessWidget {
  static const routeName = "/bt-connect";

  const BTConnectScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Connect to Bluetooth provider
    final bluetooth = Provider.of<Bluetooth>(context);
    // if bluetooth is connected, go to home screen
    if (bluetooth.isConnected) {
      print("test");
      Navigator.of(context).popUntil((route) => route.isFirst);
    }

    // if bluetooth isConnecting show a loading screen

    return Scaffold(
      appBar: AppBar(
        title: const Text("Conecta con un dispositivo"),
      ),
      body: Container(
        // add a list of device, when a device is selected, connect to it
        child: bluetooth.isConnecting
            ?
            // circular progress indicator with text "Conectando con dispositivo"
            Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const CircularProgressIndicator(),
                    // add a space between the progress indicator and the text
                    const SizedBox(height: 10),
                    Text("Conectando con ${bluetooth.deviceName}")
                  ],
                ),
              )
            : ListView.builder(
                itemCount: bluetooth.devicesList.length,
                itemBuilder: (ctx, i) {
                  // get the device
                  final device = bluetooth.devicesList[i];
                  // get the name of the devise if posible
                  final name = device.name ?? "Desconocido";
                  return ListTile(
                    title: Text(name),
                    // trailing: Icon(Icons.keyboard_arrow_right),
                    //trailing is a connection icon
                    trailing: const Icon(Icons.bluetooth),
                    onTap: () {
                      bluetooth.setDevice(device);
                    },
                  );
                }),
      ),
    );
  }
}
