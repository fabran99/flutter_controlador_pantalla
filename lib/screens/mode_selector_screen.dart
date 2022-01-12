import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../providers/settings.dart';
import '../providers/bluetooth.dart';

class ModeSelectorScreen extends StatelessWidget {
  static const routeName = "/mode-selector";

  const ModeSelectorScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Connect to settings provider
    final settings = Provider.of<Settings>(context);
    final bluetooth = Provider.of<Bluetooth>(context);

    // if bluetooth is not connected, redirect to home
    if (!bluetooth.isConnected) {
      Future.delayed(Duration.zero, () {
        Navigator.of(context).popUntil((route) => route.isFirst);
      });
      return Container();
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text("Seleccionar modo"),
        ),
        body: ListView.builder(
          itemCount: settings.availableModes.length,
          itemBuilder: (ctx, i) {
            // get current mode
            final mode = settings.availableModes[i];
            // check if mode is selected
            int value = mode['value'];
            bool isSelected = settings.currentMode == value;
            return Card(
              color: isSelected ? Colors.blue : Colors.black12,
              child: ListTile(
                leading: Icon(mode['icon']),
                title: Text(mode['description']),
                trailing: const Icon(Icons.check),
                onTap: () {
                  settings.setCurrentMode(mode['value']);
                },
              ),
            );
          },
        ));
  }
}
