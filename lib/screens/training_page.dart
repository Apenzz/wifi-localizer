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
  final TextEditingController _labelController = TextEditingController();
  final TextEditingController _xController = TextEditingController();
  final TextEditingController _yController = TextEditingController();
  List<Fingerprint> samples = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSamples();
  }

  void _loadSamples() async {
    var loaded = await StorageService.loadFingerprints();
    setState(() {
      samples = loaded;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _labelController.dispose();
    _xController.dispose();
    _yController.dispose();
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
              controller: _labelController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Label',
              ),
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // x coordinate input
              SizedBox(
                width: 115,
                child: TextField(
                  controller: _xController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'x',
                  ),
                ),
              ),
              SizedBox(width: 20),
              // y coordinate input
              SizedBox(
                width: 115,
                child: TextField(
                  controller: _yController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'y',
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {
                  var x = double.tryParse(_xController.text);
                  var y = double.tryParse(_yController.text);
                  if (x == null || y == null) return;
                  // Perform a WiFi scan.
                  var networks = await WifiService.performScan();
                  // Create fingerprint
                  setState(() {
                    samples.add(
                      Fingerprint(
                        x: x,
                        y: y,
                        label: _labelController.text,
                        networks: networks,
                        timestamp: DateTime.now(),
                      ),
                    );
                  });
                  // save samples on disk
                  await StorageService.saveFingerprints(samples);
                  print(samples);
                },
                child: Text('Collect Sample'),
              ),
              SizedBox(width: 10,),
              ElevatedButton(
                onPressed: () async {
                  setState(() {
                    samples.clear();
                  }); 
                  await StorageService.saveFingerprints(samples);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: Text('Clear All'),
              )
            ],
          ),
          SizedBox(height: 30),
          _isLoading
              ? CircularProgressIndicator()
              : samples.isEmpty
              ? Text('No samples collected yet')
              : Expanded(
                  child: ListView.builder(
                    itemCount: samples.length,
                    itemBuilder: (context, index) {
                      return Dismissible(
                        key: ValueKey(
                          samples[index].timestamp.toIso8601String(),
                        ),
                        onDismissed: (direction) async {
                          setState(() {
                            samples.removeAt(index);
                          });
                          await StorageService.saveFingerprints(samples);
                        },
                        child: ListTile(
                          title: Text(
                            samples[index].label != null
                                ? '${samples[index].label} (${samples[index].x}, ${samples[index].y})'
                                : '(${samples[index].x}, ${samples[index].y})',
                          ),
                          subtitle: Text(
                            '${samples[index].networks.length} APs detected',
                          ),
                          trailing: Text(
                            '${samples[index].timestamp.hour}:${samples[index].timestamp.minute.toString().padLeft(2, '0')}',
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ScanResultPage(
                                  networks: samples[index].networks,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }
}
