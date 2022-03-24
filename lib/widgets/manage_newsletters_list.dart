import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
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

  Future<void> saveChanges() async {
    List<dynamic> updatedList = [];

    // Save changes in the newsletters list
    for( SubscribedNewsletter newsletter in updatedNewslettersList ) {
      // adding json to updated list
      updatedList.add( newsletter.toJson() );
    }

    // replacing the contents of newsletter with the updated file
    String path = (await Utils.localPath).path;

    // opening user's newsletters list file
    File file = File( '$path/newsletterslist_' + widget.userEmail + '.json');

    file.writeAsString( jsonEncode( updatedList ) );
  }

  @override
  void dispose() {
    saveChanges();

    super.dispose();
  }
}
