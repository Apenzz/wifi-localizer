import 'package:path_provider/path_provider.dart';
import 'package:wifi_localizer/models/fingerprint.dart';
import 'dart:io';
import 'dart:convert';

class StorageService {

  static Future<void> saveFingerprints(List<Fingerprint> fingerprints) async {
    File file = await _getFile();
    await file.writeAsString(jsonEncode(fingerprints.map((f) => f.toJson()).toList()), flush: true);
  }

  static Future<List<Fingerprint>> loadFingerprints() async {
    File file = await _getFile();
    if (!await file.exists()) return [];
    final content = await file.readAsString();
    final List<dynamic> jsonList = jsonDecode(content);
    return jsonList.map((json) => Fingerprint.fromJson(json)).toList();
  }

  // little helper function to get the file path
  static Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/fingerprints.json');
  }
}