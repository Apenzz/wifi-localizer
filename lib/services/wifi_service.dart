import "package:permission_handler/permission_handler.dart";
import 'package:wifi_localizer/models/wifi_network.dart';
import 'package:wifi_scan/wifi_scan.dart';

class WifiService {
  static Future<List<WifiNetwork>> performScan() async {
    if (!await Permission.location.request().isGranted) {
      print('permission denied'); //TODO: better error handling
      return [];
    }

    final can = await WiFiScan.instance.canStartScan(askPermissions: true);
    if (can != CanStartScan.yes) {
      print('Cannot start scan'); //TODO: better error handling
      return [];
    }

    await WiFiScan.instance.startScan();
    final accessPoints = await WiFiScan.instance.onScannedResultsAvailable.first;
    
    return accessPoints.map((ap) => WifiNetwork(bssid: ap.bssid, ssid: ap.ssid, rssi: ap.level)).toList();
  }
}