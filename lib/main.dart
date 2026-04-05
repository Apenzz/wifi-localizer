import 'package:flutter/material.dart';

import 'package:wifi_localizer/screens/home_page.dart';
import 'package:wifi_localizer/screens/localize_page.dart';
import 'package:wifi_localizer/screens/training_page.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
    LocalizePage(),
    TrainingPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text(_currentIndex == 0 ? 'WiFi Scanner' : 'Training'),
        ),
        body: _pages[_currentIndex],
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (int index) {
            setState(() {
              _currentIndex = index;
            });
          }, 
          destinations: const <Widget>[
            NavigationDestination(
              icon: Icon(Icons.wifi),
              label: 'Scan',
            ),
            NavigationDestination(
              icon: Icon(Icons.navigation),
              label: 'Localize',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.location_on),
              icon: Icon(Icons.location_on_outlined),
              label: 'Train',
            ),
          ],
        ),
      ),
    );
  }
}


