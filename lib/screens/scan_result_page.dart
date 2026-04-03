import 'package:flutter/material.dart';

import 'package:wifi_localizer/models/wifi_network.dart';

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