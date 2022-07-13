import 'dart:convert';
import 'dart:io';

import 'package:googleapis/gmail/v1.dart' as gmail;
import 'package:googleapis/people/v1.dart' as people;

import 'package:flutter/material.dart';
import 'package:letter_shelf/screen_loaders/newsletterslistCheckLoader.dart';
import 'package:letter_shelf/screen_loaders/screenCheckLoader.dart';
import 'package:letter_shelf/screens/SelectAccount.dart';
import '../utils/Utils.dart';

class LoggedinUserCheckLoader extends StatefulWidget {
  const LoggedinUserCheckLoader({Key? key}) : super(key: key);

  @override
  _LoggedinUserCheckLoaderState createState() => _LoggedinUserCheckLoaderState();
}

class _LoggedinUserCheckLoaderState extends State<LoggedinUserCheckLoader> implements ScreenCheckLoader {
  late Future<void> credentialsPresent;
  late Widget redirectedScreen;
  late String userName;

  @override
  void initState() {
    super.initState();
    credentialsPresent = init();
  }

  @override
  Future<void> init() async {
    await checkForFile( null, null );
  }

  @override
  Future<void> checkForFile( gmail.GmailApi? gmailApi, people.PeopleServiceApi? peopleApi  ) async {
    redirectedScreen = await fileExists() ? NewsletterslistCheckLoader(username: userName) : const SelectAccount( ) ;
  }

  // if present, creates a reference to the credentials file stored in the documents directory
  @override
  Future<bool> fileExists() async {
    final path = ( await Utils.localPath ).path;
    File file = File( path + '/currentUser.json' );

    // if file exists fetching the current user name by reading the file
    if( await file.exists() ) {
      Map<String, dynamic> json = jsonDecode( file.readAsStringSync() );

      userName = json['user'];
      return true;

    }
    else {
      return false;
    }
  }

  @override
  FutureBuilder buildFutureBuilder() {
    return FutureBuilder(
        future: credentialsPresent,
        builder: (context, snapshot) {
          if( snapshot.connectionState == ConnectionState.done ){
            return redirectedScreen;
          }
          else if( snapshot.hasError ){
            return Scaffold(
              backgroundColor: Colors.white,
              body: Container(
                alignment: Alignment.center,
                child: Text( snapshot.error.toString() ),
              ),
            );
          }
          else {
            return Scaffold(
              body: Container(
                alignment: Alignment.center,
                child: const CircularProgressIndicator(),
              ),
            );
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return buildFutureBuilder();
  }
}