import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class Storage {
  final firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;

  Future<String> getDownloadUrl(
      String fullPath,) async {
    try {
      String downloadUrl = await storage.ref(fullPath).getDownloadURL();
      return downloadUrl;
    }
    catch( e, stacktrace ) {
      print( "getDownloadUrl" );
      print( e );
      print( stacktrace );
      return '';
    }
  }

  Future<List<String>> listImagesFile( String filePath ) async {
    firebase_storage.ListResult results = await storage.ref('images/$filePath/').listAll();
    List<String> fileNames = [];

    results.items.forEach((firebase_storage.Reference ref) => fileNames.add(ref.fullPath) );
    return fileNames;
  }

  Future<List<String>> listLogosFile( String filePath ) async {
    firebase_storage.ListResult results = await storage.ref('logos/$filePath/').listAll();
    List<String> fileNames = [];

    results.items.forEach((firebase_storage.Reference ref) => fileNames.add(ref.fullPath) );
    return fileNames;
  }
}
