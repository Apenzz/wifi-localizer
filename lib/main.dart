import 'package:flutter/material.dart';
import 'dart:math';

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

  WifiNetwork _generateFakeNetwork(int index) {
    var rng = Random();
    return WifiNetwork(
      ssid: "AP_$index",
      bssid: "${rng.nextInt(100)}:${rng.nextInt(100)}:${rng.nextInt(100)}:${rng.nextInt(100)}",
      rssi: rng.nextInt(60) - 90,
    );
  } 

  Future<List<WifiNetwork>> _performScan() async {
    // Simulate the scanning taking time
    await Future.delayed(Duration(seconds: 2));

    List<WifiNetwork> results = [];
    for (int i = 0; i < 3; i++) {
      results.add(_generateFakeNetwork(i+1));
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