import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var counter = 0;
  List<String> networks = [];

  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('WiFi Scanner'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  counter++;
                  networks.add('Network_$counter');
                });
              },  // todo
              child: Text('Scan'),
            ),
            Text('counter: $counter'),
            Expanded(
              child: ListView.builder(
                itemCount: networks.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('${networks[index]}'),
                    subtitle: Text('Strength: -${50+index} dBm'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}