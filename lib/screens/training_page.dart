import 'package:flutter/material.dart';
import 'package:wifi_localizer/models/fingerprint.dart';
import 'package:wifi_localizer/services/wifi_service.dart';

class TrainingPage extends StatefulWidget {
  @override
  State<TrainingPage> createState() => _TrainingPageState();
}

class _TrainingPageState extends State<TrainingPage> {
  final TextEditingController _controller = TextEditingController();
  List<Fingerprint> samples = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 250,
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Label',
              ),
            ),
          ),
          SizedBox(
            height: 30,
          ),
          ElevatedButton(
            onPressed:() async {
              if (_controller.text != '') {
                // Perform a WiFi scan.
                var networks = await WifiService.performScan();
                // Create fingerprint
                setState(() {
                  samples.add(Fingerprint(label: _controller.text, networks: networks, timestamp: DateTime.now()));
                });
              }
              print(samples);
            },
            child: Text('Collect Sample'),
          ),
        ],
      ),
    );
  }
}
