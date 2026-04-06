import 'dart:math';

import 'package:wifi_localizer/models/fingerprint.dart';
import 'package:wifi_localizer/models/wifi_network.dart';

enum KnnMethod { basic, weighted, adaptive, }

class KnnService {

  static ({double x, double y})? estimatePosition(List<WifiNetwork> currentScan, List<Fingerprint> fingerprints, {int k = 3, KnnMethod method = KnnMethod.basic}) {
    var distances = <({Fingerprint fp, double dist})>[];
    double x = 0.0, y = 0.0;
    
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
    
    if (method == KnnMethod.basic) {
      double sumX = 0, sumY = 0;
      for (var e in nearest) {
        sumX += e.fp.x;
        sumY += e.fp.y;
      }
      x = sumX / nearest.length;
      y = sumY / nearest.length;
    } else if (method == KnnMethod.weighted) {
      return _weightedSum(nearest);
    } else if (method == KnnMethod.adaptive) {
      var sortedDists = distances.map((e) => e.dist).toList();
      var adaptiveK = _adaptiveK(sortedDists);
      nearest = distances.take(adaptiveK).toList();
      return _weightedSum(nearest);
    }
    return (x: x, y: y);
  }

  static ({double x, double y}) _weightedSum(List<({double dist, Fingerprint fp})> nearest) {
      double weightedX = 0.0, weightedY = 0.0;
      double totalWeight = 0.0;
      for (var e in nearest) {
        var weight = e.dist == 0 ? 1000.0 : 1.0 / e.dist;
        weightedX += e.fp.x * weight;
        weightedY += e.fp.y * weight;
        totalWeight += weight;
      }
      return (x: weightedX / totalWeight, y: weightedY / totalWeight);
  }

  static int _adaptiveK(List<double> sortedDistances, {int maxK = 7, int minK = 2}) {
    for (var k = minK; k < min(maxK, sortedDistances.length); k++) {
      if (sortedDistances[k] > sortedDistances[0] * 2) {
        return k;
      }
    }
    return min(maxK, sortedDistances.length);
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