import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:letter_shelf/models/subscribed_newsletter_hive.dart';
import 'package:letter_shelf/models/subscribed_newsletters.dart';


import 'package:letter_shelf/utils/Utils.dart';
import 'package:letter_shelf/widgets/SetupScreenListTile.dart';

class ManageNewslettersList extends StatefulWidget {
  final dynamic newslettersList;
  final String userEmail;

  const ManageNewslettersList({
    Key? key,
    required this.newslettersList,
    required this.userEmail,
  }) : super(key: key);

  @override
  _ManageNewslettersListState createState() => _ManageNewslettersListState();
}

class _ManageNewslettersListState extends State<ManageNewslettersList> {
  List<SubscribedNewsletter> updatedNewslettersList = [];

  Future<void> saveChanges() async {
    List<dynamic> updatedList = [];

    // replacing the contents of newsletter with the updated file
    String path = (await Utils.localPath).path;

    // opening user's newsletters list file
    File file = File( '$path/newsletterslist_' + widget.userEmail + '.json');
    List<dynamic> fileData = jsonDecode( file.readAsStringSync() );

    List<SubscribedNewsletter> uniqueNewsletters = [];

    // check for duplicates, if not duplicate adding to the newsletters list
    for( SubscribedNewsletter newsletter in updatedNewslettersList ) {
      bool flag = true;

      for( var i in uniqueNewsletters ) {
        if( i.name == newsletter.name && i.email == newsletter.email ) {
          flag = false;
          break;
        }
      }

      if( flag ) {
        uniqueNewsletters.add( newsletter );
      }
    }
    
    file.writeAsString( jsonEncode( uniqueNewsletters ) );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: ListView.builder(itemBuilder: (context, index) {
        if(widget.newslettersList[index]['enabled'] != null )
        {
          // creating new object of SubscribedNewsletter
          SubscribedNewsletter letter = SubscribedNewsletter(
            name: widget.newslettersList[index]['name'],
            email: widget.newslettersList[index]['email'],
            enabled: widget.newslettersList[index]['enabled'],
          );

          updatedNewslettersList.add(letter);

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
            child: SetupScreenListTile( newsletter: letter, ),
          );
        }
        else {
          return Container();
        }
      },
        itemCount: widget.newslettersList.length ,
      ),
    );
  }

  @override
  void dispose() {
    saveChanges();
    super.dispose();
  }
}
