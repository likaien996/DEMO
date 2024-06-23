import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:food_deliver/utils/utils_logger.dart';

class UploadService {
  const UploadService._();

  static Future<String> uploadPic(String path) async {
    try {
      final storageRef = FirebaseStorage.instance.ref();
      final mountainsRef =
          storageRef.child("${DateTime.now().millisecondsSinceEpoch}.jpg");
      await mountainsRef.putFile(File(path));
      return await mountainsRef.getDownloadURL();
    } catch (e) {
      LoggerUtils.e(e);
    }
    return "";
  }
}
