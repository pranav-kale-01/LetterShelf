import 'dart:io';

import 'package:flutter/material.dart';
import 'package:googleapis/gmail/v1.dart' as gmail;
import 'package:googleapis/people/v1.dart' as people;

import 'package:letter_shelf/screen_loaders/loggedinuserCheckLoader.dart';
import 'package:letter_shelf/screen_loaders/screenCheckLoader.dart';

import '../screens/SignInScreen.dart';
import '../utils/Utils.dart';

class CredentialCheckLoader extends StatefulWidget {
  const CredentialCheckLoader({Key? key}) : super(key: key);

  @override
  _CredentialCheckLoaderState createState() => _CredentialCheckLoaderState();
}

class _CredentialCheckLoaderState extends State<CredentialCheckLoader> implements ScreenCheckLoader {
  late Future<void> credentialsPresent;
  late Widget redirectedScreen;

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
  Future<void> checkForFile( gmail.GmailApi? gmailApi, people.PeopleServiceApi? peoplApi ) async {
    redirectedScreen = await fileExists() ? const LoggedinUserCheckLoader() : const SignInScreen() ;
  }

  // if present, creates a reference to the credentials file stored in the documents directory
  @override
  Future<bool> fileExists() async {
    final path = await Utils.localPath;
    final files = path.listSync();

    RegExp re = RegExp(r'credentials');
    bool filePresent = false;

    for( FileSystemEntity ent in files ) {
      if( re.hasMatch(ent.toString() ) ) {
        filePresent = true;
      }
    }
    return filePresent;
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
