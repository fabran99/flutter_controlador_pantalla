import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './providers/bluetooth.dart';
import './providers/settings.dart';
import 'screens/bt_connect_screen.dart';
import 'screens/mode_selector_screen.dart';
import 'screens/options_screen.dart';
import 'screens/modifiers_screen.dart';
import 'screens/custom_drawing_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(
            value: Bluetooth(),
          ),
          // add a proxi provider for the settings that takes the bluetooth provider
          // as a dependency
          ChangeNotifierProxyProvider<Bluetooth, Settings>(
            update: (ctx, bluetooth, _) => Settings(bluetooth),
            create: (ctx) => Settings(Bluetooth()),
          ),
        ],
        child: Consumer<Bluetooth>(
          builder: (ctx, bluetooth, _) => MaterialApp(
            title: "Screen Controller",
            theme: ThemeData(
              primarySwatch: Colors.blue,
              brightness: Brightness.light,
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
            ),
            themeMode: ThemeMode.dark,
            debugShowCheckedModeBanner: false,
            home: bluetooth.isConnected
                ? OptionsScreen()
                : const BTConnectScreen(),
            routes: {
              OptionsScreen.routeName: (ctx) => OptionsScreen(),
              ModeSelectorScreen.routeName: (ctx) => const ModeSelectorScreen(),
              ModifiersScreen.routeName: (ctx) => const ModifiersScreen(),
              CustomDrawingScreen.routeName: (ctx) => CustomDrawingScreen(),
            },
          ),
        ));
  }
}
