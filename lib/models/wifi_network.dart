
class WifiNetwork {
  final String bssid;
  final String ssid;
  final int rssi;

  WifiNetwork({required this.bssid, required this.ssid, required this.rssi});

  Map<String, dynamic> toJson() {
    return {
      'bssid': bssid,
      'ssid': ssid,
      'rssi': rssi,
    };
  }

  factory WifiNetwork.fromJson(Map<String, dynamic> json) {
    return WifiNetwork(
      bssid: json['bssid'] as String,
      ssid: json['ssid'] as String,
      rssi: json['rssi'] as int
    );
  }
}