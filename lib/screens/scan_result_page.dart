import 'package:flutter/material.dart';

import 'package:wifi_localizer/models/wifi_network.dart';

class ScanResultPage extends StatelessWidget {
  final List<WifiNetwork> networks;

  ScanResultPage({required this.networks});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Network Scan Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: networks.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(networks[index].ssid),
              subtitle: Text(networks[index].bssid),
              trailing: Text(
                '${networks[index].rssi} dBm',
                textScaler: TextScaler.linear(1.35),
              ),
            );
          },
        ),
      ),
    );
  }
}
