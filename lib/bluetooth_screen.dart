import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothScreen extends StatefulWidget {
  const BluetoothScreen({super.key});

  @override
  State<BluetoothScreen> createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends State<BluetoothScreen> {
  List<ScanResult> scanResults = [];
  Map<String, BluetoothConnectionState> deviceStates = {}; // Track device states

  @override
  void initState() {
    super.initState();
    FlutterBluePlus.scanResults.listen((results) {
      setState(() {
        for (var result in results) {
          // Use the advertisementData to get details (check for name)
          String deviceName = result.advertisementData.advName.isNotEmpty
              ? result.advertisementData.advName
              : "Unknown Device"; // Fallback if no name is found

          // Avoid duplicates based on device ID
          if (!scanResults.any((r) => r.device.remoteId == result.device.remoteId)) {
            scanResults.add(result);
          }

          debugPrint("Device found: $deviceName (ID: ${result.device.remoteId})");
        }
      });
    });
  }

  void startScan() {
    setState(() {
      scanResults.clear(); // Clear previous results before scanning
    });
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));
  }

  void connectOrDisconnectDevice(BluetoothDevice device) async {
    try {
      BluetoothConnectionState state = await device.connectionState.first;

      if (state == BluetoothConnectionState.connected) {
        // If the device is connected, disconnect it
        await device.disconnect();
        setState(() {
          deviceStates[device.remoteId.toString()] = BluetoothConnectionState.disconnected;
        });
        debugPrint("Disconnected from ${device.platformName}");
      } else {
        // If the device is not connected, connect to it
        await device.connect();
        setState(() {
          deviceStates[device.remoteId.toString()] = BluetoothConnectionState.connected;
        });
        debugPrint("Connected to ${device.platformName}");
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Bluetooth Scanner")),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: startScan,
            child: const Text("Scan for Devices"),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: scanResults.length,
              itemBuilder: (context, index) {
                final device = scanResults[index].device;
                String deviceName = device.platformName.isNotEmpty
                    ? device.platformName
                    : "Unknown Device";

                // Get the current device state
                BluetoothConnectionState currentState = deviceStates[device.remoteId.toString()] ?? BluetoothConnectionState.disconnected;

                return ListTile(
                  title: Text(deviceName),
                  subtitle: Text(device.remoteId.toString()),
                  trailing: ElevatedButton(
                    onPressed: () => connectOrDisconnectDevice(device),
                    child: Text(currentState == BluetoothConnectionState.connected ? "Disconnect" : "Connect"),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
