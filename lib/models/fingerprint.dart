import 'package:wifi_localizer/models/wifi_network.dart';

// A Fingerprint instance is the result of a single WiFi scan in the Training data collection phase
class Fingerprint {
  final String label;
  final List<WifiNetwork> networks;
  final DateTime timestamp;

  Fingerprint({required this.label, required this.networks, required this.timestamp});

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'networks': networks.map((n) => n.toJson()).toList(),
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory Fingerprint.fromJson(Map<String, dynamic> json) {
    return Fingerprint(
      label: json['label'] as String,
      networks: (json['networks'] as List).map((n) => WifiNetwork.fromJson(n)).toList(),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}