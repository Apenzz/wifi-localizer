import 'dart:math';

import 'package:wifi_localizer/models/fingerprint.dart';
import 'package:wifi_localizer/models/wifi_network.dart';

class KnnService {

  static ({double x, double y})? estimatePosition(List<WifiNetwork> currentScan, List<Fingerprint> fingerprints, {int k = 3}) {
    var distances = <({Fingerprint fp, double dist})>[];
    
    for (var fingerprint in fingerprints) {
      var distance = _euclideanDistance(currentScan, fingerprint.networks);
      distances.add((fp: fingerprint, dist: distance));
    }
    // Filter out infinite distances
    distances.removeWhere((e) => e.dist == double.infinity);
    if (distances.isEmpty) return null;
    // Sort by distance ascending
    distances.sort((a, b) => a.dist.compareTo(b.dist));
    // Take first k
    var nearest = distances.take(k).toList();
    // Average x and y
    double sumX = 0, sumY = 0;
    for (var e in nearest) {
      sumX += e.fp.x;
      sumY += e.fp.y;
    }
    return (x: sumX / nearest.length, y: sumY / nearest.length);
  }

  static double _euclideanDistance(List<WifiNetwork> scan1, List<WifiNetwork> scan2) {
    // Build a map of BSSID -> RSSI for scan1
    var map1 = {for (var n in scan1) n.bssid: n.rssi};
    double sum = 0;
    int shared = 0;

    for (var n in scan2) {
      if (map1.containsKey(n.bssid)) {
        sum += pow(map1[n.bssid]! -  n.rssi, 2);
        shared++;
      }
    }

    if (shared == 0) return double.infinity;
    return sqrt(sum);
  }
}