import 'dart:io';
import 'package:path_provider/path_provider.dart';

class Utils {
  // returns the local path to the documents directory
  static Future<Directory> get localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory;
  }

}