import 'package:flutter/material.dart';
import 'package:wifi_localizer/services/wifi_service.dart';

import 'package:wifi_localizer/models/wifi_network.dart';
import 'package:wifi_localizer/screens/scan_result_page.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isScanning = false;
  List<WifiNetwork> networks = [];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: _isScanning
                ? null
                : () async {
                    setState(() {
                      _isScanning = true;
                    });
                    var results = await WifiService.performScan();

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
                              builder: (context) =>
                                  ScanResultPage(networks: networks),
                            ),
                          );
                        },
                        child: ListTile(
                          title: Text(networks[index].ssid),
                          subtitle: Text(networks[index].bssid),
                          trailing: Text('${networks[index].rssi}'),
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
