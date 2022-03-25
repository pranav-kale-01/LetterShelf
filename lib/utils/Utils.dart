import 'dart:io';
import 'package:path_provider/path_provider.dart';

class Utils {
  static bool firstHomeScreenLoad = true;

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


  static String getInitials( String fullText ) {
    String initials='';

    // generating text for circle-Avatar using the Name of the newsletter
    // separating each word of the name
    List<String> wordsList = fullText.split(' ');

    // taking first or first two letters from the list
    int index=0;
    while( index<wordsList.length && index<2 ) {
      // taking the first letter of every Word
      initials += wordsList[index][0];

      index+=1;
    }

    return initials;
  }
}