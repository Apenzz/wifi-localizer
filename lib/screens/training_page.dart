import 'package:flutter/material.dart';
import 'dart:io';
import 'package:wifi_localizer/models/fingerprint.dart';
import 'package:wifi_localizer/screens/scan_result_page.dart';
import 'package:wifi_localizer/services/image_service.dart';
import 'package:wifi_localizer/services/storage_service.dart';
import 'package:wifi_localizer/services/wifi_service.dart';
import 'package:wifi_localizer/widgets/floor_plan_widget.dart';

class TrainingPage extends StatefulWidget {
  @override
  State<TrainingPage> createState() => _TrainingPageState();
}

class _TrainingPageState extends State<TrainingPage> {
  final TextEditingController _labelController = TextEditingController();
  List<Fingerprint> samples = [];
  double? _tapX, _tapY;
  File? imageFloor;

  @override
  void initState() {
    super.initState();
    _loadSamples();
    _loadImage();
  }

  void _loadImage() async {
    var image = await ImageService.retrieveImage();
    setState(() {
      imageFloor = image;
    });
  }

  void _loadSamples() async {
    var loaded = await StorageService.loadFingerprints();
    setState(() {
      samples = loaded;
    });
  }

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main content
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: Column(
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
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      if (_tapX == null || _tapY == null) return;
                      var networks = await WifiService.performScan();
                      setState(() {
                        samples.add(
                          Fingerprint(
                            x: _tapX!,
                            y: _tapY!,
                            label: _labelController.text,
                            networks: networks,
                            timestamp: DateTime.now(),
                          ),
                        );
                      });
                      await StorageService.saveFingerprints(samples);
                    },
                    child: Text('Collect Sample'),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () async {
                      var confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Clear All'),
                          content: Text(
                            'Are you sure? This action will delete all collected samples.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        setState(() {
                          samples.clear();
                        });
                        await StorageService.saveFingerprints(samples);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Clear All'),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: FloorPlanWidget(
                  imageFloor: imageFloor,
                  position: _tapX != null && _tapY != null
                      ? (x: _tapX!, y: _tapY!)
                      : null,
                  trainingPoints: samples
                      .map((s) => (x: s.x, y: s.y))
                      .toList(),
                  onTap: (x, y) {
                    setState(() {
                      _tapX = x;
                      _tapY = y;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
        // Draggable bottom sheet
        DraggableScrollableSheet(
          initialChildSize: 0.15,
          minChildSize: 0.15,
          maxChildSize: 1.0,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
              ),
              child: ListView.builder(
                controller: scrollController,
                itemCount: samples.length + 1,
                itemBuilder: (context, index) {
                  // Drag handle
                  if (index == 0) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    );
                  }
                  var sample = samples[index - 1];
                  return Dismissible(
                    key: ValueKey(sample.timestamp.toIso8601String()),
                    onDismissed: (direction) async {
                      setState(() {
                        samples.removeAt(index - 1);
                      });
                      await StorageService.saveFingerprints(samples);
                    },
                    child: ListTile(
                      title: Text(
                        sample.label != null
                            ? '${sample.label} (${sample.x.toStringAsFixed(1)}, ${sample.y.toStringAsFixed(1)})'
                            : '(${sample.x.toStringAsFixed(1)}, ${sample.y.toStringAsFixed(1)})',
                      ),
                      subtitle: Text('${sample.networks.length} APs detected'),
                      trailing: Text(
                        '${sample.timestamp.hour}:${sample.timestamp.minute.toString().padLeft(2, '0')}',
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ScanResultPage(networks: sample.networks),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            );
          },
        ),
        // FAB
        Positioned(
          bottom: 40.0,
          right: 40.0,
          child: FloatingActionButton(
            child: Icon(Icons.image),
            onPressed: () async {
              var image = await ImageService.pickImage();
              if (image != null) {
                imageCache.clear();
                imageCache.clearLiveImages();
                setState(() {
                  imageFloor = image;
                });
              }
            },
          ),
        )
      ],
    );
  }
}
