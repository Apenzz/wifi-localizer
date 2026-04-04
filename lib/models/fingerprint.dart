import 'package:wifi_localizer/models/wifi_network.dart';

// A Fingerprint instance is the result of a single WiFi scan in the Training data collection phase
class Fingerprint {
  final String label;
  final List<WifiNetwork> networks;
  final DateTime timestamp;

  Fingerprint({required this.label, required this.networks, required this.timestamp});
}