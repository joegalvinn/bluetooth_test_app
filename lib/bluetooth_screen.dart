import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothScreen extends StatefulWidget {
  const BluetoothScreen({super.key});

  @override
  State<BluetoothScreen> createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends State<BluetoothScreen> {
  List<ScanResult> scanResults = [];

  @override
  void initState() {
    super.initState();
    // Listen to scan results and update UI dynamically
    FlutterBluePlus.scanResults.listen((results) {
      setState(() {
        for (var result in results) {
          // Avoid duplicates
          if (!scanResults.any((r) => r.device.remoteId == result.device.remoteId)) {
            scanResults.add(result);
          }
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

  void connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect();
      debugPrint("Connected to ${device.platformName}");
    } catch (e) {
      debugPrint("Error connecting: $e");
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
                return ListTile(
                  title: Text(device.platformName.isNotEmpty
                      ? device.platformName
                      : "Unknown Device"),
                  subtitle: Text(device.remoteId.toString()),
                  trailing: ElevatedButton(
                    onPressed: () => connectToDevice(device),
                    child: const Text("Connect"),
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
