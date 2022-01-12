import 'dart:convert';
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
// For using PlatformException
import 'package:flutter/services.dart';

class Bluetooth with ChangeNotifier {
  // Initializing the Bluetooth connection state to be unknown
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;
  // Get the instance of the Bluetooth
  FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;
// Track the Bluetooth connection with the remote device
  BluetoothConnection? connection;
  bool isConnecting = false;

  int _deviceState = 0;
  String _deviceName = 'Unknown';
  bool _isDisconnecting = false;

  // To track whether the device is still connected to Bluetooth
  bool get isConnected => (connection?.isConnected ?? false);

  // Define some variables, which will be required later
  List<BluetoothDevice> _devicesList = [];
  BluetoothDevice? _device;
  bool _connected = false;

  List<BluetoothDevice> get devicesList => _devicesList;
  int get deviceState => _deviceState;
  String get deviceName => _deviceName;

  setDevice(BluetoothDevice device) async {
    _device = device;
    _deviceName = device.name ?? 'Unknown';
    notifyListeners();
    connect();
  }

  // initialize the Bluetooth connection
  Future<void> initialize() async {
    // To get the current state of Bluetooth
    FlutterBluetoothSerial.instance.state.then((state) {
      _bluetoothState = state;

      notifyListeners();
    });

    _deviceState = 0; // neutral
    notifyListeners();
    // If the bluetooth of the device is not enabled,
    // then request permission to turn on bluetooth
    // as the app starts up
    enableBluetooth();

    // Listen for further state changes
    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      _bluetoothState = state;
      print("========================================");
      print(_bluetoothState);
      print("========================================");
      notifyListeners();
      getPairedDevices();
    });
  }

  // Request Bluetooth permission from the user
  Future<bool> enableBluetooth() async {
    // Retrieving the current Bluetooth state
    _bluetoothState = await FlutterBluetoothSerial.instance.state;

    // If the bluetooth is off, then turn it on first
    // and then retrieve the devices that are paired.
    if (_bluetoothState == BluetoothState.STATE_OFF) {
      await FlutterBluetoothSerial.instance.requestEnable();
      await getPairedDevices();
      return true;
    } else {
      await getPairedDevices();
    }
    return false;
  }

  // For retrieving and storing the paired devices
  // in a list.
  Future<void> getPairedDevices() async {
    List<BluetoothDevice> devices = [];

    // To get the list of paired devices
    try {
      devices = await _bluetooth.getBondedDevices();
    } on PlatformException {
      print("Error");
    }
    // Store the [devices] list in the [_devicesList] for accessing
    // the list outside this class
    _devicesList = devices;
    notifyListeners();

    // loop over devicesList, if the name of the devices is saved in preferences, connect to it
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // String? dname = prefs.getString('connectedDeviceName');
    // if (dname != null) {
    //   for (BluetoothDevice d in _devicesList) {
    //     if (d.name == dname) {
    //       setDevice(d);
    //       break;
    //     }
    //   }
    // }
  }

  void manualDisconnect() async {
    print("Desconectando manualmente");
    _isDisconnecting = true;
    connection?.close();
    connection = null;
    _connected = false;
    // clear the preferences saved
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('connectedDeviceName');
    notifyListeners();
  }

  void sendMessageToBluetooth(String message) async {
    if (isConnected) {
      connection!.output.add(Uint8List.fromList(utf8.encode(message)));
    }
    // send all data
    await connection!.output.allSent;
  }

  void sendCurrentTime() async {
    DateTime now = DateTime.now();
    String message = "<T";
    // time should go YYYYMMDDHHMMSS
    message += now.year.toString().padLeft(4, '0');
    message += now.month.toString().padLeft(2, '0');
    message += now.day.toString().padLeft(2, '0');
    message += now.hour.toString().padLeft(2, '0');
    message += now.minute.toString().padLeft(2, '0');
    message += now.second.toString().padLeft(2, '0');
    message += ">";
    sendMessageToBluetooth(message);
  }

  // Method to disconnect bluetooth
  // Future<void> disconnect() async {
  //   _deviceState = 0;

  //   await connection?.close();
  //   if (connection != null && connection.isConnected)) {
  //     _connected = false;
  //   }
  //   notifyListeners();
  // }

  void _onDataReceived(Uint8List data) {
    print(data);
  }

  // Method to connect to bluetooth
  void connect() async {
    if (_device == null) {
      print('No device selected');
    } else {
      isConnecting = true;
      notifyListeners();
      if (!isConnected) {
        await BluetoothConnection.toAddress(_device?.address)
            .then((_connection) {
          print('Connected to the device');
          connection = _connection;
          _connected = true;
          isConnecting = false;
          // save connected device name as json
          notifyListeners();
          saveConnectedDeviceName();

          connection!.input!.listen(_onDataReceived).onDone(() {
            print('disconnected manual');
            _connected = false;
            isConnecting = false;
            _deviceState = 0;
            _device = null;
            _deviceName = "Unknown";
            notifyListeners();

            // if(!_isDisconnecting) {
            //   connect();
            // }
          });
        }).catchError((error) {
          print('Cannot connect, exception occurred');
          // wait for 2 seconds, and try again
          Timer(const Duration(seconds: 1), () {
            connect();
          });
        });
      }
    }
  }

  void saveConnectedDeviceName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('connectedDeviceName', _deviceName);
  }

  void setPixelColor(color, int pixel) {
    String message = "<P";
    message += pixel.toString().padLeft(3, '0');
    message += color.red.toString().padLeft(3, '0');
    message += color.green.toString().padLeft(3, '0');
    message += color.blue.toString().padLeft(3, '0');
    message += ">";
    sendMessageToBluetooth(message);
  }

  Bluetooth() {
    initialize();
  }
}
