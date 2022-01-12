import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import './bluetooth.dart';

String get3DigitFromInt(int n) {
  if (n < 10) {
    return "00" + n.toString();
  } else if (n < 100) {
    return "0" + n.toString();
  } else {
    return n.toString();
  }
}

class Settings with ChangeNotifier {
  int _currentMode = 0;
  bool _horizontal = false;
  bool _reverseGradient = false;
  bool _randomizeDark = false;
  bool _gradientMode = false;
  Bluetooth bluetooth;
  Color _color1 = Color.fromRGBO(0, 255, 149, 1);
  Color _color2 = Color.fromRGBO(0, 136, 255, 1);
  int _minHue = 0;
  int _maxHue = 255;
  int _ledBrightness = 20;

  final int _rows = 6;
  final int _cols = 18;

  // availableModes is a list of dicts with a description as string, value as int and icon as Icon
  final List<Map<String, dynamic>> availableModes = [
    {
      "description": "Reloj",
      "icon": Icons.access_time,
      "value": 0,
    },
    {
      "description": "Color plano / Degradado",
      "icon": Icons.gradient,
      "value": 1,
    },
    {
      "description": "Lineas de colores",
      "icon": Icons.arrow_forward,
      "value": 2,
    },
    {
      "description": "Dibujo manual",
      "icon": Icons.brush,
      "value": 3,
    },
    {
      "description": "Animacion Custom",
      "icon": Icons.animation,
      "value": 4,
    },
    {
      "description": "Puntos al azar",
      "icon": Icons.shuffle,
      "value": 5,
    },
    {
      "description": "Efecto Matrix",
      "icon": Icons.grid_on,
      "value": 6,
    },
    {
      "description": "Arcoiris",
      "icon": Icons.color_lens,
      "value": 7,
    },
    {
      "description": "Particulas",
      "icon": Icons.blur_on,
      "value": 8,
    },
    {
      "description": "Mar",
      "icon": Icons.waves,
      "value": 9,
    }
  ];

  Settings(this.bluetooth);

  int get currentMode => _currentMode;
  bool get horizontal => _horizontal;
  bool get reverseGradient => _reverseGradient;
  bool get randomizeDark => _randomizeDark;
  bool get gradientMode => _gradientMode;
  Color get color1 => _color1;
  Color get color2 => _color2;
  int get minHue => _minHue;
  int get maxHue => _maxHue;
  int get ledBrightness => _ledBrightness;
  int get rows => _rows;
  int get cols => _cols;

  void setLedBrightness(int brightness) {
    _ledBrightness = brightness;
    notifyListeners();
    String message = "<L${get3DigitFromInt(brightness)}>";
    print(message);
    bluetooth.sendMessageToBluetooth(message);
  }

  void setCurrentMode(int mode) {
    _currentMode = mode;
    notifyListeners();
    String message = "<M$_currentMode";
    if (currentMode == 2) {
      message += get3DigitFromInt(_minHue);
      message += get3DigitFromInt(_maxHue);
    }
    message += ">";
    bluetooth.sendMessageToBluetooth(message);
  }

  void setHorizontal(bool horizontal) {
    _horizontal = horizontal;
    notifyListeners();
    int n = _horizontal ? 1 : 0;
    bluetooth.sendMessageToBluetooth("<H$n>");
  }

  void setReverseGradient(bool reverseGradient) {
    _reverseGradient = reverseGradient;
    notifyListeners();
    int n = _reverseGradient ? 1 : 0;
    bluetooth.sendMessageToBluetooth("<R$n>");
  }

  void setRandomizeDark(bool randomizeDark) {
    _randomizeDark = randomizeDark;
    notifyListeners();
    int n = _randomizeDark ? 1 : 0;
    bluetooth.sendMessageToBluetooth("<D$n>");
  }

  void setGradientMode(bool gradientMode) {
    _gradientMode = gradientMode;
    notifyListeners();
    int n = _gradientMode ? 1 : 0;
    bluetooth.sendMessageToBluetooth("<G$n>");
  }

  void setColor1(Color color) {
    _color1 = color;
    notifyListeners();
    bluetooth.sendMessageToBluetooth(
        "<A${get3DigitFromInt(color.red)}${get3DigitFromInt(color.green)}${get3DigitFromInt(color.blue)}>");
  }

  void setColor2(color) {
    _color2 = color;
    notifyListeners();
    bluetooth.sendMessageToBluetooth(
        "<B${get3DigitFromInt(color.red)}${get3DigitFromInt(color.green)}${get3DigitFromInt(color.blue)}>");
  }

  void setMinHue(int minHue) {
    _minHue = minHue;
    notifyListeners();
  }

  void setMaxHue(int maxHue) {
    _maxHue = maxHue;
    notifyListeners();
  }
}
