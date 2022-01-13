import 'package:flutter/material.dart';
import 'mode_selector_screen.dart';
import 'modifiers_screen.dart';
import 'custom_drawing_screen.dart';
import 'package:provider/provider.dart';
import "../providers/bluetooth.dart";

class OptionsScreen extends StatelessWidget {
  static const routeName = "/home";

  const OptionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bluetooth = Provider.of<Bluetooth>(context);

    // if is not connected, go to home
    if (!bluetooth.isConnected) {
      Future.delayed(Duration.zero, () {
        Navigator.of(context).popUntil((route) => route.isFirst);
      });
      return Container();
    }

    final List<Map<String, dynamic>> options = [
      {
        "route": ModifiersScreen.routeName,
        "title": "Modificar efectos/colores",
        "icon": Icons.color_lens
      },
      {
        "route": ModeSelectorScreen.routeName,
        "title": "Selector de modo",
        "icon": Icons.settings
      },
      {
        "route": CustomDrawingScreen.routeName,
        "title": "Dibujo personalizado",
        "icon": Icons.brush
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Opciones"),
      ),
      // Add a ListView to the body of the screen. This will populate the screen with the list of options.
      body: ListView.builder(
        itemCount: options.length,
        itemBuilder: (context, index) {
          final currentOption = options[index];

          return Padding(
            // padding: const EdgeInsets.all(25.0),
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            child: Card(
              // add the icon centered with 100% width
              child: InkWell(
                onTap: () {
                  Navigator.of(context).pushNamed(currentOption['route']);
                },
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      // add the icon with a black background and padding of 8
                      Container(
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                          currentOption["icon"],
                          color: Colors.white,
                          size: 100,
                        ),
                      ),
                      // Icon(currentOption["icon"], size: 100),
                      const SizedBox(
                        height: 15,
                      ),
                      Text(
                        currentOption["title"],
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
