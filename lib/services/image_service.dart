import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class ImageService {
  static const fileName = 'floor_plan.jpg';

  static Future<File?> pickImage() async {
    final picker = ImagePicker();
    final floorMap = await picker.pickImage(source: ImageSource.gallery);
    if (floorMap == null) return null;
    // Save image in persistent storage
    final dir = await getApplicationDocumentsDirectory();
    final savedImage = await File(floorMap.path).copy('${dir.path}/$fileName');
    return savedImage;
  }

  static Future<File?> retrieveImage() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$fileName');
    if (await file.exists()) {
      return file;
    }
    return null;
  }
}
