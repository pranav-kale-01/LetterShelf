import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:letter_shelf/utils/OAuthClient.dart';
import 'package:letter_shelf/utils/Utils.dart';

import 'package:googleapis/gmail/v1.dart' as gmail;
import 'package:letter_shelf/widgets/manage_newsletters_list.dart';

import 'add_new_newsletters.dart';

class UserNewsletterList extends StatefulWidget {
  final gmail.GmailApi gmailApi;

  const UserNewsletterList({Key? key, required this.gmailApi})
      : super(key: key);

  @override
  _UserNewsletterListState createState() => _UserNewsletterListState();
}

class _UserNewsletterListState extends State<UserNewsletterList> {
  late dynamic jsonObject;
  late Future<void> loadingCompleted;
  late String userEmail;

  @override
  void initState() {
    super.initState();

    loadingCompleted = init();
  }

  Future<void> init() async {
      // fetching user's email address from api
      userEmail = await OAuthClient.getCurrentUserNameFromApi( widget.gmailApi );

      // getting local path
      String path = (await Utils.localPath).path;

      // opening user's newsletters list file
      File file = File( '$path/newsletterslist_' + userEmail + '.json');

      jsonObject = jsonDecode( file.readAsStringSync( ) );
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
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric( horizontal: 8.0),
            child: IconButton(
              icon: Icon( Icons.add ),
              onPressed: () async {
                List<dynamic> result = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AddNewNewsletters( gmailApi: widget.gmailApi ),
                  )
                );

                setState(() {
                  jsonObject = result;
                });
              },
            ),
          )
        ],
      ),
      body: FutureBuilder(
        future: loadingCompleted,
        builder: (context, snapshot ) {
          if( snapshot.connectionState == ConnectionState.done ) {
            return ManageNewslettersList( newslettersList: jsonObject, userEmail: userEmail, );
          }
          else if( snapshot.hasError ) {
            return Container(
              alignment: Alignment.center,
              child: Text( snapshot.error.toString() ),
            );
          }
          else {
            return Container(
              alignment: Alignment.center,
              child: const CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
