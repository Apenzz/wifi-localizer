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
  var counter = 0;
  List<WifiNetwork> networks = [];

  WifiNetwork _generateFakeNetwork() {
    var rng = Random();
    return WifiNetwork(
      ssid: "AP_$counter",
      bssid: "${rng.nextInt(100)}:${rng.nextInt(100)}:${rng.nextInt(100)}:${rng.nextInt(100)}",
      rssi: rng.nextInt(60) - 90,
    );
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
              onPressed: () {
                setState(() {
                  var networks = [];
                  for (int i = 0; i < 3; i++) {
                    counter++;
                    networks.add(_generateFakeNetwork());
                  }
                });
              },  // todo
              child: Text('Scan'),
            ),
            Text('counter: $counter'),
            Expanded(
              child: ListView.builder(
                itemCount: networks.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('${networks[index].ssid}'),
                    subtitle: Text('${networks[index].bssid}'),
                    trailing: Text('${networks[index].rssi}'),
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

class WifiNetwork {
  final String bssid;
  final String ssid;
  final int rssi;

  WifiNetwork({required this.bssid, required this.ssid, required this.rssi});
}