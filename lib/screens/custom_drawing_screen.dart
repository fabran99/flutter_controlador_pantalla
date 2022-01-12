import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import '../providers/settings.dart';
import '../providers/bluetooth.dart';
import 'package:flutter/services.dart';

class CustomDrawingScreen extends StatefulWidget {
  static const routeName = '/custom-drawing';

  @override
  _CustomDrawingScreenState createState() => _CustomDrawingScreenState();
}

class _CustomDrawingScreenState extends State<CustomDrawingScreen> {
  Color customColor = Colors.blue;
  Color selectedColor = Colors.blue;
  List<Color> pixelList = [];

  final defaultColorList = [
    Colors.red.shade900,
    Colors.orange.shade600,
    Colors.yellow,
    Colors.green,
    Colors.blue.shade800,
    Colors.indigo,
    Colors.purple,
    Colors.pink.shade700,
    Colors.black,
    Colors.white,
    Colors.grey,
    Colors.brown.shade800,
    Colors.cyan,
    Colors.teal.shade600,
  ];

  void onCustomColorChange(Color color) {
    setState(() {
      customColor = color;
    });
  }

  void onSelectedColorChange(Color color) {
    setState(() {
      selectedColor = color;
    });
  }

  // on init state, change the settings.mode to 4
  @override
  void initState() {
    final settings = Provider.of<Settings>(context, listen: false);
    // for every row and column, add a black color to the list
    for (int i = 0; i < settings.rows; i++) {
      for (int j = 0; j < settings.cols; j++) {
        pixelList.add(Colors.black);
      }
    }
    settings.setCurrentMode(3);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.initState();
  }

  // before dispose, change setPrefferedOrientation back to portrait
  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  void onTapPixel(int pixel) {
    setState(() {
      pixelList[pixel] = selectedColor;
      // get bluetooth provider
      final bluetooth = Provider.of<Bluetooth>(context, listen: false);
      // send the pixel to the arduino
      bluetooth.setPixelColor(selectedColor, pixel);
    });
  }

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
    final bluetooth = Provider.of<Bluetooth>(context);
    final settings = Provider.of<Settings>(context);

    // if is not connected, go to home
    if (!bluetooth.isConnected) {
      return Container();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dibujo personalizado'),
      ),
      body:
          // center the content
          SingleChildScrollView(
        child: Center(
          child: Column(children: <Widget>[
            // add a box with rows and columns with gesture detector
            Padding(
              padding: const EdgeInsets.fromLTRB(45, 5, 25, 5),
              child: Flex(
                direction: Axis.vertical,
                children: List.generate(settings.rows, (row) {
                  return Flex(
                    direction: Axis.horizontal,
                    children: List.generate(settings.cols, (col) {
                      int currentPixel = row * settings.cols + col;
                      return GestureDetector(
                        onTapDown: (_) {
                          onTapPixel(currentPixel);
                        },
                        child: Container(
                          width: 38,
                          height: 38,
                          // add a border to the box
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey.shade800,
                              width: 1,
                            ),
                            color: pixelList[currentPixel],
                          ),
                        ),
                      );
                    }),
                  );
                }),
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            // add a list of clickable squares that sets the current color
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Flex(direction: Axis.horizontal, children: <Widget>[
                ...defaultColorList.map(
                  (color) => Flexible(
                    flex: 1,
                    child: GestureDetector(
                      onTapDown: (_) {
                        onSelectedColorChange(color);
                      },
                      child: Container(
                        margin: const EdgeInsets.all(5),
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          // if the color is the selected color, add a border
                          border: Border.all(
                            color: selectedColor == color
                                ? Colors.white
                                : Colors.transparent,
                            width: 2,
                          ),
                          color: color,
                        ),
                      ),
                    ),
                  ),
                ),
                // add a spaced box of 100 width
                const SizedBox(
                  width: 50,
                ),
                // add a box with the custom color
                GestureDetector(
                  onTapDown: (details) {
                    onSelectedColorChange(customColor);
                  },
                  onLongPress: () async {
                    if (!(await colorPickerDialog())) {}
                  },
                  child: Container(
                    margin: const EdgeInsets.all(5),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      // if the color is the selected color, add a border
                      border: Border.all(
                        color: selectedColor == customColor
                            ? Colors.white
                            : Colors.transparent,
                        width: 2,
                      ),
                      color: customColor,
                    ),
                  ),
                ),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  Future<bool> colorPickerDialog() async {
    return ColorPicker(
      color: customColor,
      onColorChanged: (Color color) {
        setState(() {
          customColor = color;
          selectedColor = color;
        });
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
