import 'package:flutter/material.dart';
import 'package:wifi_scan/wifi_scan.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isScanning = false;
  List<WifiNetwork> networks = [];

  Future<List<WifiNetwork>> _performScan() async {
    List<WifiNetwork> results = [];

    if (!await _permissionGranted()) {
      print('Could not scan for networks!');
      return results;
    } 
    await _startScan(); // start scanning
    await Future.delayed(Duration(seconds: 2));
    return _getScannerResults(results); // scan results
  }

  Future<bool> _permissionGranted() {
    return Permission.location.request().isGranted;
  } 

  // trigger full WiFi Scan
  Future<void> _startScan() async {
    // check platform support for any necessary requirements
    final can = await WiFiScan.instance.canStartScan(askPermissions: true);
    switch(can) {
      case CanStartScan.yes:
        // start full scan async-ly
        final success = await WiFiScan.instance.startScan();
        if (!success) { print('Scan did not trigger'); }
      default:
        print('Failed to scan');
    }
  }

  // get scanner results and save them into networks
  Future<List<WifiNetwork>> _getScannerResults(List<WifiNetwork> results) async {
    final can = await WiFiScan.instance.canGetScannedResults(askPermissions: true);
    switch(can) {
      case CanGetScannedResults.yes:
      // get scanned results
      final accessPoints = await WiFiScan.instance.getScannedResults();
      for (var ap in accessPoints) {
        results.add(WifiNetwork(bssid: ap.bssid, ssid: ap.ssid, rssi: ap.level));
      }
      default:
        print('Cannot get Scan Results');
    }
    return results;
  }

  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('WiFi Scanner'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _isScanning ? null : () async {
                setState(() {
                  _isScanning = true; 
                });
                var results = await _performScan();

                setState(() {
                  networks = results;
                  _isScanning = false;
                });
              },
              child: Text('Scan'),
            ),
            _isScanning
              ? CircularProgressIndicator()
              : Expanded(
              child: ListView.builder(
                itemCount: networks.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ScanResultPage(network: networks[index]),
                        ),
                       );
                    },
                    child: ListTile(
                      title: Text('${networks[index].ssid}'),
                      subtitle: Text('${networks[index].bssid}'),
                      trailing: Text('${networks[index].rssi}'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ScanResultPage extends StatelessWidget {
  final WifiNetwork network;

  ScanResultPage({required this.network});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Network details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('SSID: ${network.ssid}'),
            Text('BSSID: ${network.bssid}'),
            Text('RSSI: ${network.rssi} dBm'),
          ],
        ),
      ),
    );
  }
}

class WifiNetwork {
  final String bssid;
  final String ssid;
  final int rssi;

  WifiNetwork({required this.bssid, required this.ssid, required this.rssi});
}