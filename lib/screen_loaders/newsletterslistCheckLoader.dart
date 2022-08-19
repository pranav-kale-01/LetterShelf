import 'dart:io';

import 'package:flutter/material.dart';

import 'package:letter_shelf/screens/HomeScreen.dart';
import 'package:letter_shelf/screens/SetupScreen.dart';
import 'package:letter_shelf/utils/Utils.dart';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/gmail/v1.dart' as gmail;
import 'package:googleapis/people/v1.dart' as people;
import 'package:letter_shelf/utils/google_auth_client.dart';

class NewsletterListCheckLoader extends StatefulWidget {
  final GoogleSignInAccount user;

  const NewsletterListCheckLoader({Key? key,
    required this.user,
  }) : super(key: key);

  @override
  _NewsletterListCheckLoaderState createState() =>
      _NewsletterListCheckLoaderState();
}

class _NewsletterListCheckLoaderState extends State<NewsletterListCheckLoader> {
  late Future<void> newsletterListPresent;
  late Widget redirectedScreen;

  late gmail.GmailApi gmailApi;
  late people.PeopleServiceApi peopleApi;

  @override
  void initState() {
    super.initState();
    newsletterListPresent = init();
  }

  Future<void> init() async {
    try {
      final authHeaders = await widget.user.authHeaders;
      final authenticatedClient =  GoogleAuthClient( authHeaders );

      gmailApi = gmail.GmailApi(authenticatedClient);
      peopleApi = people.PeopleServiceApi( authenticatedClient );

      await checkForFile(widget.user);
    }
    catch (e, stacktrace) {
      debugPrint(e.toString());
      debugPrint(stacktrace.toString());
    }
  }

  Future<void> checkForFile(GoogleSignInAccount user) async {
    final bool exists = await fileExists();
    redirectedScreen = exists ? HomeScreen(user: user, gmailApi: gmailApi, peopleApi: peopleApi, ) : SetupScreen( user: user,);
  }

  Future<bool> fileExists() async {
    final directory = await Utils.localPath;
    List<FileSystemEntity> files = directory.listSync();

    RegExp re = RegExp(r'newsletterslist_' + widget.user.email + '.json');
    bool fileExists = false;

    for (FileSystemEntity ent in files) {
      if (re.hasMatch(ent.toString())) {
        fileExists = true;
      }
    }

    return fileExists;
  }


  Widget buildFutureBuilder() {
    return FutureBuilder(
        future: newsletterListPresent,
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
