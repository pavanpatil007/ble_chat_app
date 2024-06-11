import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';

class BLEController extends GetxController {
  final FlutterBluePlus flutterBlue = FlutterBluePlus();
  RxBool isScanning = false.obs;
  RxList<BluetoothDevice> devices = <BluetoothDevice>[].obs;
  Rx<BluetoothDevice?> connectedDevice = Rx<BluetoothDevice?>(null);
  RxList<String> messages = <String>[].obs;
  BluetoothCharacteristic? writeCharacteristic;

  @override
  void onInit() {
    super.onInit();
    _requestPermissions();
  }

  void _requestPermissions() async {
    if (await Permission.bluetoothScan.request().isGranted &&
        await Permission.bluetoothConnect.request().isGranted &&
        await Permission.location.request().isGranted) {
      _startScan();
    } else {
      // Handle permission denied scenario
      print("Permissions not granted");
    }
  }

  void _startScan() {
    isScanning.value = true;
    FlutterBluePlus.startScan(timeout: Duration(seconds: 20)).then((_) {
      isScanning.value = false;
    });

    FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult r in results) {
        if (!devices.contains(r.device)) {
          devices.add(r.device);
        }
      }
    });
  }

  void connectToDevice(BluetoothDevice device) async {
    int retryCount = 3;
    while (retryCount > 0) {
      try {
        await device.connect(timeout: Duration(seconds: 5));
        connectedDevice.value = device;
        _setupDeviceCommunication();
        return;
      } catch (e) {
        retryCount--;
        if (retryCount == 0) {
          print("Failed to connect after multiple attempts: $e");
        } else {
          await Future.delayed(Duration(seconds: 2));
        }
      }
    }
  }

  void _setupDeviceCommunication() async {
    var services = await connectedDevice.value?.discoverServices();
    if (services != null) {
      for (var service in services) {
        for (var characteristic in service.characteristics) {
          if (characteristic.properties.notify) {
            characteristic.setNotifyValue(true);
            characteristic.value.listen((value) {
              String receivedMessage = utf8.decode(value);
              receiveMessage(receivedMessage);
            });
          }
          if (characteristic.properties.write) {
            writeCharacteristic = characteristic;
          }
        }
      }
    }
  }

  void disconnectFromDevice() {
    connectedDevice.value?.disconnect();
    connectedDevice.value = null;
  }

  void sendMessage(String message) {
    if (writeCharacteristic != null && connectedDevice.value != null) {
      List<int> messageBytes = utf8.encode(message);
      writeCharacteristic!.write(messageBytes);
      messages.add("Me: $message");
    }
  }

  void receiveMessage(String message) {
    messages.add("Them: $message");
  }
}
