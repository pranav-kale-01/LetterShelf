import 'dart:io';
import 'package:path_provider/path_provider.dart';

class Utils {
  // returns the local path to the documents directory
  static Future<Directory> get localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory;
  }

  static Future<bool> hasNetwork() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }
}