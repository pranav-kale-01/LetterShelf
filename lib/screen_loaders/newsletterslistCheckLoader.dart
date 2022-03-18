import 'dart:io';

import 'package:flutter/material.dart';
import 'package:googleapis/gmail/v1.dart' as gmail;
import 'package:googleapis_auth/auth_io.dart';
import 'package:letter_shelf/screen_loaders/screenCheckLoader.dart';
import 'package:letter_shelf/screens/HomeScreen.dart';
import 'package:letter_shelf/screens/SetupScreen.dart';
import 'package:letter_shelf/utils/OAuthClient.dart';

import '../utils/Utils.dart';

class NewsletterslistCheckLoader extends StatefulWidget {
  final String username;

  const NewsletterslistCheckLoader({Key? key, required this.username})
      : super(key: key);

  @override
  _NewsletterslistCheckLoaderState createState() =>
      _NewsletterslistCheckLoaderState();
}

class _NewsletterslistCheckLoaderState extends State<NewsletterslistCheckLoader> implements ScreenCheckLoader {
  late Future<void> newsletterslistPresent;
  late Widget redirectedScreen;

  @override
  void initState() {
    super.initState();
    newsletterslistPresent = init();
  }

  @override
  Future<void> init() async {
    try {
      AutoRefreshingAuthClient? authClient = await OAuthClient(username: widget.username).getClient( );
      gmail.GmailApi api = gmail.GmailApi(authClient);
      await checkForFile(api);
    }
    catch (exc) {
      debugPrint(exc.toString());
    }
  }

  @override
  Future<void> checkForFile(gmail.GmailApi? api) async {
    final bool exists = await fileExists();
    redirectedScreen =
        exists ? HomeScreen(gmailApi: api!) : SetupScreen(gmailApi: api!);
  }

  @override
  Future<bool> fileExists() async {
    final directory = await Utils.localPath;
    List<FileSystemEntity> files = directory.listSync();

    RegExp re = RegExp(r'newsletterslist_' + widget.username + '.json');
    bool fileExists = false;

    for (FileSystemEntity ent in files) {
      if (re.hasMatch(ent.toString())) {
        fileExists = true;
      }
    }

    return fileExists;
  }

  @override
  FutureBuilder buildFutureBuilder() {
    return FutureBuilder(
        future: newsletterslistPresent,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return redirectedScreen;
          } else if (snapshot.hasError) {
            return Scaffold(
              body: Container(
                alignment: Alignment.center,
                child: Text(snapshot.error.toString()),
              ),
            );
          } else {
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
