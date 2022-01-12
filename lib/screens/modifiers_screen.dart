import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import '../providers/settings.dart';
import '../providers/bluetooth.dart';

class ModifiersScreen extends StatefulWidget {
  static const routeName = "/modifiers";

  const ModifiersScreen({Key? key}) : super(key: key);

  @override
  State<ModifiersScreen> createState() => _ModifiersScreenState();
}

class _ModifiersScreenState extends State<ModifiersScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bluetooth = Provider.of<Bluetooth>(context);
    if (!bluetooth.isConnected) {
      Future.delayed(Duration.zero, () {
        // go to home screen
        Navigator.of(context).popUntil((route) => route.isFirst);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // connect to settings provider
    final settings = Provider.of<Settings>(context);
    final bluetooth = Provider.of<Bluetooth>(context);
    print("Rerun modifiers");

    // if is not connected, go to home
    if (!bluetooth.isConnected) {
      // Future.delayed(Duration.zero, () {
      //   Navigator.of(context).pushReplacementNamed('/');
      // });
      return Container();
    }

    final List<Map<String, dynamic>> toggleElements = [
      {
        "text": "Modo degradado",
        "value": settings.gradientMode,
        "func": settings.setGradientMode,
        "subtitle": "Alternar entre modo degradado o color plano"
      },
      {
        "text": "Oscurecer pixeles aleatoriamente",
        "value": settings.randomizeDark,
        "func": settings.setRandomizeDark,
        "subtitle": "Aplica en los modos degradado y reloj"
      },
      {
        "text": "Degradado horizontal",
        "value": settings.horizontal,
        "func": settings.setHorizontal,
        "subtitle": "Direccion del degradado"
      },
    ];

    return Scaffold(
        appBar: AppBar(
          title: const Text("Modificar efectos/colores"),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Text(
                  "Colores",
                  style: TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 20),
                //==========================
                // Colores
                //==========================
                // add color picker for settings.color1
                ListTile(
                  title: const Text("Color 1"),
                  subtitle: const Text(
                    "Afecta a reloj/degradado",
                    style: TextStyle(fontSize: 12),
                  ),
                  trailing: ColorIndicator(
                    width: 40,
                    height: 40,
                    borderRadius: 0,
                    color: settings.color1,
                    onSelect: () async {
                      var onChange = (Color color) {
                        settings.setColor1(color);
                      };
                      if (!(await colorPickerDialog(
                          settings.color1, onChange))) {}
                    },
                  ),
                ),
                ListTile(
                  title: const Text("Color 2"),
                  subtitle: const Text(
                    "Afecta a reloj/degradado",
                    style: TextStyle(fontSize: 12),
                  ),
                  trailing: ColorIndicator(
                    width: 40,
                    height: 40,
                    borderRadius: 0,
                    color: settings.color2,
                    onSelect: () async {
                      var onChange = (Color color) {
                        settings.setColor2(color);
                      };
                      if (!(await colorPickerDialog(
                          settings.color2, onChange))) {}
                    },
                  ),
                ),
                //==========================
                // Brillo
                //==========================

                const Divider(thickness: 1),
                const SizedBox(height: 20),
                const Text(
                  "Brillo",
                  style: TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 20),
                //==========================
                Slider(
                  min: 0,
                  max: 255,
                  value: settings.ledBrightness.toDouble(),
                  divisions: 255,
                  onChanged: (value) {
                    settings.setLedBrightness(value.toInt());
                  },
                ),
                const SizedBox(height: 5),
                const Text(
                  "Brillos muy altos pueden dar problemas en algunos modos",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),

                //==========================
                // Opciones extra
                //==========================
                const SizedBox(height: 20),
                const Divider(thickness: 1),
                const SizedBox(height: 20),
                const Text(
                  "Modificadores",
                  style: TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 20),

                ...toggleElements.map((element) {
                  return Row(
                    // align items in 3 equal columns
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(element['text']),
                          Text(
                            element['subtitle'],
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          )
                        ],
                      )),
                      Switch(
                        value: element['value'],
                        onChanged: (value) {
                          element['func'](value);
                        },
                      ),
                      ElevatedButton(
                        child: const Text("Aplicar"),
                        onPressed: () {
                          element['func'](element['value']);
                        },
                      ),
                    ],
                  );
                }),

                //==========================
                // Opciones extra
                //==========================
                const SizedBox(height: 20),
                const Divider(thickness: 1),
                const SizedBox(height: 20),
                const Text(
                  "Opciones extra",
                  style: TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 20),
                Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text("Aplicar hora actual"),
                        Text(
                          "Actualiza la hora del reloj",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    child: const Text("Aplicar"),
                    onPressed: () {
                      bluetooth.sendCurrentTime();
                    },
                  )
                ]),
                Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text("Desconectar dispositivo"),
                        Text(
                          "Termina la conexion con el dispositivo",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    child: const Text("Aplicar"),
                    onPressed: () {
                      // Navigator.of(context).pushReplacementNamed('/');
                      bluetooth.manualDisconnect();
                    },
                  )
                ])
              ],
            ),
          ),
        ));
  }

  Future<bool> colorPickerDialog(Color color, onChange) async {
    return ColorPicker(
      color: color,
      onColorChanged: (Color color) {
        onChange(color);
      },
      width: 40,
      height: 40,
      borderRadius: 4,
      spacing: 5,
      runSpacing: 5,
      wheelDiameter: 155,
      heading: const Text(
        'Selecciona el color',
      ),
      subheading: const Text(
        'Selecciona tono del color',
      ),
      wheelSubheading: const Text(
        'Selecciona color y tono',
      ),
      showMaterialName: false,
      showColorName: false,
      showColorCode: false,
      copyPasteBehavior: const ColorPickerCopyPasteBehavior(
        longPressMenu: true,
      ),
      pickersEnabled: const <ColorPickerType, bool>{
        ColorPickerType.both: false,
        ColorPickerType.primary: true,
        ColorPickerType.accent: true,
        ColorPickerType.bw: false,
        ColorPickerType.custom: true,
        ColorPickerType.wheel: true,
      },
    ).showPickerDialog(
      context,
      constraints:
          const BoxConstraints(minHeight: 480, minWidth: 300, maxWidth: 320),
    );
  }
}
