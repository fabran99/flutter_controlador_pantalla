import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './providers/bluetooth.dart';
import './providers/settings.dart';
import 'screens/bt_connect_screen.dart';
import 'screens/mode_selector_screen.dart';
import 'screens/options_screen.dart';
import 'screens/modifiers_screen.dart';
import 'screens/options_screen.dart';
import 'screens/custom_drawing_screen.dart';
import 'screens/color_picker_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
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
            title: 'Flutter Demo',
            theme: ThemeData(
              primarySwatch: Colors.blue,
              brightness: Brightness.light,
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
            ),
            themeMode: ThemeMode.dark,
            debugShowCheckedModeBanner: false,
            home: bluetooth.isConnected ? OptionsScreen() : BTConnectScreen(),
            routes: {
              OptionsScreen.routeName: (ctx) => OptionsScreen(),
              ModeSelectorScreen.routeName: (ctx) => ModeSelectorScreen(),
              ModifiersScreen.routeName: (ctx) => ModifiersScreen(),
              CustomDrawingScreen.routeName: (ctx) => CustomDrawingScreen(),
            },
          ),
        ));
  }
}
