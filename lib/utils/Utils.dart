import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class Utils {
  static bool firstHomeScreenLoadUnread = true;
  static bool firstHomeScreenLoadRead = true;
  static bool firstProfileScreenLoad = true;
  static bool firstInboxScreenLoad = true;
  static bool firstExploreScreenLoad = true;
  static String username = '';

  static final List<Color> backgroundColorsList = [
    Color( Colors.pinkAccent.value ),
    Color( Colors.blue.value ),
    Color( Colors.green.value),
    Color( Colors.deepPurple.value ),
    Color( Colors.deepOrangeAccent.value ),
    Color( Colors.tealAccent.value ),
    Color( Colors.teal.value )
  ];

  static Map<String,bool> loadedScreens = {};

  // returns the local path to the documents directory
  static Future<Directory> get localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory;
  }

  static Future<bool> hasNetwork() async {
    try {
      final result = await InternetAddress.lookup('www.google.com');
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

  static T getRandomElement<T>(List<T> list) {
    final random = new Random();
    var i = random.nextInt(list.length);
    return list[i];
  }


  static bool firstScreenLoad( String screenName, [bool? value] ) {
    if( loadedScreens[screenName] == null ) {
      loadedScreens[screenName] = false;
      return false;
    }
    else if( value != null ) {
      loadedScreens[screenName] = value;
      return value;
    }

    return loadedScreens[screenName]!;
  }

  static Color getBackgroundColor( String displayText ) {
    // getting the first character of the display text
    displayText = displayText.toUpperCase();

    double colorPerIndex = 27 / Utils.backgroundColorsList.length;

    if( displayText.codeUnitAt(0) <= 92 && displayText.codeUnitAt(0) >= 65) {
      int colorIndex =  ( (displayText.codeUnitAt(0) - 64) / colorPerIndex ).floor() ;
      try {
        return Utils.backgroundColorsList[ colorIndex ];
      }
      catch( e ) {
        print( displayText );
        print( ((displayText.codeUnitAt(0) - 64) / colorPerIndex ) );
        print( 'pleease not from here - ' +  colorIndex.toString() );
        return Colors.pink;
      }
    }
    else {
      return Utils.getRandomElement(backgroundColorsList);
    }
  }
}