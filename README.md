# Wifi Localizer

A mobile app for WiFi-based indoor localization using RSSI fingerprinting and k-NN positioning algorithms.

## Installation

### Requirements
- Flutter SDK (3.9+)
- Android SDK
- A physical Android device (WiFi scanning requires real hardware)

### Setup
1. Clone the repository
```bash
    git clone https://github.com/Apenzz/wifi-localizer.git
    cd wifi_localizer
```
2. Install dependencies
```bash
    flutter pub get
```
3. Add your floor plan image (jpg or png) in `assets/`
4. Run on a physical device
```bash
    flutter run
```

## Usage

### Training Phase
1. Navigate to the **Train** tab
2. Stand at a known location in your building
3. Tap your position on the floor plan
4. Optionally add a label (e.g. "north hallway")
5. Press **Collect Sample**
6. Repeat at 10-20 different locations, collecting 5-10 samples per location

### Localization Phase
1. Navigate to the **Localize** tab
2. Select a positioning algorithm (kNN, weighted kNN, adaptive weighted kNN)
3. Toggle **Live Position** on
4. Your estimated position appears as a dot on the floor plan, updating every 5 seconds

## Demo
![App Demo](screenshots/demo.gif)