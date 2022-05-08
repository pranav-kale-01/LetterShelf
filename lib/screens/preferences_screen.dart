import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../utils/Utils.dart';

class PreferredScreen extends StatefulWidget {
  const PreferredScreen({Key? key}) : super(key: key);

  @override
  _PreferredScreenState createState() => _PreferredScreenState();
}

class _PreferredScreenState extends State<PreferredScreen> {
  bool _value = true;

  @override
  void initState() {
    super.initState();

    init();
  }

  void init() async {
    String path = ( await Utils.localPath ).path;
    String username = Utils.username;

    // opening user's newsletters list file
    File file = File( '$path/preferences_' + username + '.json');
    file.createSync();

    String fileData = file.readAsStringSync();
    if( fileData.isEmpty ) {
      return;
    }

    Map<String,dynamic> jsonData = jsonDecode( fileData );
    if( jsonData['show_images_on_tile'] == null ) {
      _value = false;
    }
    else {
      _value = jsonData['show_images_on_tile'];
    }

    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
        backgroundColor: Colors.white,
        title: const Text(
          'Manage Newsletters',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      body: Column(
        children: [
          // Manage Newsletters List
          Container(
            margin: EdgeInsets.symmetric( horizontal: 7, vertical: 1),
            child: GestureDetector(
              onTap: () {
              },
              child: Container(
                height: 80,
                child: Card(
                  elevation: 1,
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.only(left: 15),
                          child: const Text(
                            "Show Images On Tile",
                            style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w400
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        child: CupertinoSwitch(
                            value: _value,
                            onChanged: (value) async {
                              _value = value;
                              String path = ( await Utils.localPath ).path;
                              String username = Utils.username;

                              // opening user's newsletters list file
                              File file = File( '$path/preferences_' + username + '.json');
                              file.createSync();

                              Map<String,dynamic> jsonData = jsonDecode( file.readAsStringSync() );
                              jsonData['show_images_on_tile'] = _value;

                              file.writeAsStringSync( jsonEncode(jsonData)) ;

                              setState(() {

                              });
                            }),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
