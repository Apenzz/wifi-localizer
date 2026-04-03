import 'package:wifi_localizer/models/wifi_network.dart';

// A Fingerprint instance is the result of a single WiFi scan in the Training data collection phase
class Fingerprint {
  final String label;
  final List<WifiNetwork> networks;
  final DateTime timestamp;

  Fingerprint(this.label, this.networks, this.timestamp);
}