import 'package:flutter/material.dart';
import 'package:wifi_localizer/services/storage_service.dart';
import 'dart:async';
import 'package:wifi_localizer/services/knn_service.dart';
import 'package:wifi_localizer/services/wifi_service.dart';
import 'package:wifi_localizer/models/fingerprint.dart';

class LocalizePage extends StatefulWidget {
  @override
  State<LocalizePage> createState() => _LocalizePageState();
}

class _LocalizePageState extends State<LocalizePage> {
  bool light = false; // whether the switch if on
  final countdown = 5; // Seconds between each position estimation
  Timer? _timer;
  List<Fingerprint> fingerprints = [];
  ({double x, double y})? _position;

  @override
  void initState() {
    super.initState();
    _loadSamples();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _loadSamples() async {
    var loaded = await StorageService.loadFingerprints();
    setState(() {
      fingerprints = loaded;
    });
  }

  void _startLocalization() async {
    var results = await WifiService.performScan();
    setState(() {
      _position = KnnService.estimatePosition(results, fingerprints);
    });

    _timer = Timer.periodic(Duration(seconds: countdown), (timer) async {
      var results = await WifiService.performScan();
      setState(() {
        _position = KnnService.estimatePosition(results, fingerprints);
      });
    });
  }

  void _stopLocalization() {
    _timer?.cancel();
    setState(() {
      _position = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text('Coordinates: '),
          Switch(
            value: light,
            onChanged: fingerprints.isEmpty ? null : (bool value) {
              setState(() {
                light = value;
              });
              value ? _startLocalization() : _stopLocalization();
            },
          ),
          Expanded(
            child: _position == null
              ? Text('No positions estimated')
              : Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset('assets/planimetria_casa.jpg'),
                  ),
                  Positioned(
                    left: 200, // TODO: fix hardcoded coordinates
                    top: 150,
                    child: Container(
                      width: 15,
                      height: 15,
                      decoration: BoxDecoration(
                        color: Colors.lightBlueAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
          ),
        ],
      ),
    );
  }
}
