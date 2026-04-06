import 'package:flutter/material.dart';
import 'package:wifi_localizer/services/storage_service.dart';
import 'dart:async';
import 'package:wifi_localizer/services/knn_service.dart';
import 'package:wifi_localizer/services/wifi_service.dart';
import 'package:wifi_localizer/models/fingerprint.dart';
import 'package:wifi_localizer/widgets/floor_plan_widget.dart';

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
  KnnMethod _method = KnnMethod.basic;

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
      _position = KnnService.estimatePosition(results, fingerprints, method: _method);
    });

    _timer = Timer.periodic(Duration(seconds: countdown), (timer) async {
      var results = await WifiService.performScan();
      setState(() {
        _position = KnnService.estimatePosition(results, fingerprints, method: _method);
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
          SegmentedButton(
            selected: <KnnMethod>{_method},
            onSelectionChanged: (newSelection) {
              setState(() {
                _method = newSelection.first;
              });
            },
            segments: [
              ButtonSegment(value: KnnMethod.basic, label: Text('kNN')),
              ButtonSegment(value: KnnMethod.weighted, label: Text('wkNN')),
              ButtonSegment(value: KnnMethod.adaptive, label: Text('sawkNN')),
            ],
          ),
          Text('Coordinates: '),
          Switch(
            value: light,
            onChanged: fingerprints.isEmpty
                ? null
                : (bool value) {
                    setState(() {
                      light = value;
                    });
                    value ? _startLocalization() : _stopLocalization();
                  },
          ),
          Expanded(
            child: _position == null
                ? Text('No positions estimated')
                : FloorPlanWidget(
                  position: _position,
                ),
          ),
        ],
      ),
    );
  }
}