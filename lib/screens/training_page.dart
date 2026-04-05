import 'package:flutter/material.dart';
import 'package:wifi_localizer/models/fingerprint.dart';
import 'package:wifi_localizer/screens/scan_result_page.dart';
import 'package:wifi_localizer/services/storage_service.dart';
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
    _loadSamples(); 
  }

  void _loadSamples() async {
    var loaded = await StorageService.loadFingerprints();
    setState(() {
      samples = loaded;
    });
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
          SizedBox(height: 30),
          ElevatedButton(
            onPressed: () async {
              if (_controller.text != '') {
                // Perform a WiFi scan.
                var networks = await WifiService.performScan();
                // Create fingerprint
                setState(() {
                  samples.add(
                    Fingerprint(
                      label: _controller.text,
                      networks: networks,
                      timestamp: DateTime.now(),
                    ),
                  );
                });
                // save samples on disk
                await StorageService.saveFingerprints(samples);
              }
              print(samples);
            },
            child: Text('Collect Sample'),
          ),
          SizedBox(height: 30,),
          samples.isEmpty
            ? Text('No samples collected yet')
            : Expanded(
            child: ListView.builder(
              itemCount: samples.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  child: ListTile(
                    title: Text(samples[index].label),
                    subtitle: Text('${samples[index].networks.length} APs detected'),
                    trailing: Text('${samples[index].timestamp.hour}:${samples[index].timestamp.minute.toString().padLeft(2, '0')}'),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ScanResultPage(networks: samples[index].networks),
                      )
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
