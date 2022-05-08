import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:googleapis/gmail/v1.dart' as gmail;
import '../models/subscribed_newsletters.dart';
import '../utils/OAuthClient.dart';
import '../utils/Utils.dart';

class AddNewNewslettersListTile extends StatefulWidget {
  final SubscribedNewsletter newsletter;
  final gmail.GmailApi gmailApi;

  const AddNewNewslettersListTile({Key? key, required this.gmailApi, required this.newsletter}) : super(key: key);

  @override
  _AddNewNewslettersListTileState createState() => _AddNewNewslettersListTileState();
}

class _AddNewNewslettersListTileState extends State<AddNewNewslettersListTile> {
  late String initials;
  late Color backgroundColor;

  @override
  void initState() {
    super.initState();

    initials = Utils.getInitials(widget.newsletter.name);
    backgroundColor = Utils.getBackgroundColor(initials);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: backgroundColor,
          radius: 25,
          child: Text(
              initials,
              style: TextStyle(
                color: Colors.white,
              ),
          ),
        ),
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
          child: Text(
            widget.newsletter.name,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 3.0),
          child: Text(
            widget.newsletter.email,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        trailing: Transform.scale(
          scale: 0.9,
          child: IconButton(
            icon: Icon( Icons.add ),
            onPressed: () async {
              // replacing the contents of newsletter with the updated file
              String path = (await Utils.localPath).path;

              final String username = await OAuthClient.getCurrentUserNameFromApi( widget.gmailApi );

              // opening user's newsletters list file
              File file = File( '$path/newsletterslist_' + username + '.json');

              List<dynamic> jsonData = jsonDecode( file.readAsStringSync() );

              bool flag = true;
              for( var i in jsonData ){
                if( i['name'] == widget.newsletter.name && i['email'] == widget.newsletter.email ) {
                  flag = false;
                  break;
                }
              }

              if( flag ) {
                jsonData.add({
                  "name": widget.newsletter.name,
                  "email": widget.newsletter.email,
                  "enabled": true,
                });

                file.writeAsString( jsonEncode( jsonData ) );
              }


              Navigator.of(context).pop( jsonData );
            },
          )
        ),
      ),
    );
  }
}
