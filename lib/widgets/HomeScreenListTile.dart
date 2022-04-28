import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/gmail/v1.dart' as gmail;
import 'package:hive/hive.dart';
import 'package:letter_shelf/models/emailMessage.dart';
import 'package:http/http.dart' as http;


import '../utils/Utils.dart';
import '../utils/hive_services.dart';
import 'MessageBody.dart';

class HomeScreenListTile extends StatefulWidget {
  final gmail.GmailApi gmailApi;
  final Function addToListMethod;
  final Function removeFromListMethod;
  final String listKey;
  final String username;
  EmailMessage emailMessage;
  Color headerColor = Colors.black;

  HomeScreenListTile({
    Key? key,
    required this.gmailApi,
    required this.emailMessage,
    required this.addToListMethod,
    required this.removeFromListMethod,
    required this.listKey,
    required this.username
  }) : super(key: key);

  @override
  _HomeScreenListTileState createState() => _HomeScreenListTileState();
}

class _HomeScreenListTileState extends State<HomeScreenListTile> {
  final HiveServices hiveService = HiveServices( );
  String circleAvatarText = "";
  bool executeOnTap = true;
  late BuildContext ctx;
  Image? image;
  Color backgroundColor = Colors.pinkAccent;

  final monthData = {
    "1": "Jan",
    "2": "Feb",
    "3": "Mar",
    "4": "Apr",
    "5": "May",
    "6": "June",
    "7": "Jul",
    "8": "Aug",
    "9": "Sep",
    "10": "Oct",
    "11": "Nov",
    "12": "Dec"
  };

  void loadMessage() {
    if (executeOnTap) {
      executeOnTap = false;
      _loadEmailMessageBody(
          widget.emailMessage.subject, widget.emailMessage.msgId);
    }
  }

  Future<void> _loadEmailMessageBody(
      String messageSubject, String messageId) async {
    Navigator.of(ctx).push(
      MaterialPageRoute(
        builder: (context) => MessageBody(
            api: widget.gmailApi,
            messageSubject: messageSubject,
            messageId: messageId),
      ),
    );

    executeOnTap = true;
  }

  @override
  void initState() {
    super.initState();

    circleAvatarText = Utils.getInitials(widget.emailMessage.from);
    backgroundColor = Utils.getBackgroundColor( circleAvatarText );
    getBackgroundImage();
  }

  Future<void> getBackgroundImage() async {

    bool exists = await hiveService.isExists( boxName: widget.emailMessage.from + "CachedImage" );

    if(exists) {
      List<dynamic> tempList = await hiveService.getBoxes( widget.emailMessage.from + "CachedImage" );
      Uint8List rawImage = Uint8List.fromList( List<int>.from( tempList ) );
      image = Image.memory( rawImage);
      setState(() {

      });
    }
    else {
      Future.delayed(const Duration( seconds: 1), () async {
        // creating a reference of firebase db
        FirebaseFirestore db = FirebaseFirestore.instance;

        // showing the list of available newsletter emails
        DocumentSnapshot snapshot = await db.collection("newsletters_list").doc( widget.emailMessage.from ).get();

        if( snapshot.data() != null ) {
          Map<String, dynamic> decodedData = jsonDecode( jsonEncode( snapshot.data() ) );

          if(decodedData['image'] != null ) {
            Uint8List rawImage = Uint8List.fromList( List<int>.from( decodedData['image'] ) );

            Box _box = await Hive.openBox( widget.emailMessage.from + "CachedImage" );
            _box.deleteAll(_box.keys);

            await hiveService.addBoxes( rawImage, widget.emailMessage.from + "CachedImage");
            image = Image.memory( rawImage);

            setState(() {

            });
          }
        }
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    ctx = context;

    return SizedBox(
      height: 190,
      child: Card(
        elevation: 1,
        child: Column(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () async {
                  // checking if the newsletter is unread
                  List<dynamic> tempList = await hiveService.getBoxes( " is:unread CachedMessages" + widget.username );

                  if (  widget.emailMessage.unread ) {
                    setState(() {
                      // now inserting new data to previous cached data
                      for( var msg in tempList ) {
                        if( msg['msgId'] == widget.emailMessage.msgId ) {
                          msg['unread'] = false;
                          break;
                        }
                      }

                      hiveService.addBoxes( tempList, " is:unread CachedMessages" + widget.username );

                      // setting the font color to light gray
                      widget.headerColor = Colors.grey;

                      // also changing the unread property of the current email message to false
                      // (if we don't change the property, the next time ListTile is reloaded, there would be no way to tell if the message was read)
                      widget.emailMessage.unread = false;

                      // removing the message from unread and adding it to the top of read messages list
                      // widget.removeFromListMethod( widget.emailMessage.msgId );
                      // widget.addToListMethod( listName: 'UNREAD', msg: widget.emailMessage );

                      // modifying the messages label to remove UNREAD Label from the message
                      gmail.ModifyMessageRequest req = gmail.ModifyMessageRequest(
                          removeLabelIds: [
                            "UNREAD"
                          ]
                      );

                      widget.gmailApi.users.messages.modify( req, 'me', widget.emailMessage.msgId);
                    });
                  }
                  loadMessage();
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: image == null ? 4 : 0, right: 4, top: 15),
                      child: image == null ? CircleAvatar(
                        backgroundColor: backgroundColor,
                        radius: 32,
                        child: Text(
                            circleAvatarText,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w600
                            ),
                        ),
                      ) : SizedBox(
                        width: 74,
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50)
                          ),
                          elevation: 2,
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: image
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.74,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.only(top: 15, bottom: 3, left: 10),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              widget.emailMessage.from,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: widget.listKey != "[<'READ'>]" && widget.emailMessage.unread ? widget.headerColor : Colors.grey,
                                fontWeight: FontWeight.w500,
                                fontSize: 24,
                              ),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(bottom: 6, top: 5, left: 10),
                            child: Text(
                              widget.emailMessage.subject,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 3,
                              strutStyle: const StrutStyle(
                                height: 1,
                              ),
                              style: TextStyle(
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              alignment: Alignment.bottomRight,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                  '${monthData[widget.emailMessage.date.month.toString()]} ${widget.emailMessage.date.day}'),
            ),
            Container(
              height: 1,
              margin: EdgeInsets.only(top: 8),
              color: Colors.black12,
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 1, vertical: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.white,
                        elevation: 0
                      ) ,
                      onPressed: () {},
                      child: Container(
                          color: Colors.white,
                          alignment: Alignment.center,
                          // padding: EdgeInsets.symmetric(vertical: 8),
                          child: Icon(
                            Icons.star_border,
                            color: Colors.black87,
                          ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.white,
                        elevation: 0
                      ) ,
                      onPressed: () {},
                      child: Container(
                          color: Colors.white,
                          alignment: Alignment.center,
                          // padding: EdgeInsets.symmetric(vertical: 8),
                          child: Icon(
                            Icons.label_important_outline,
                            color: Colors.black87,
                          ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.white,
                        elevation: 0
                      ) ,
                      onPressed: () {},
                      child: Container(
                          color: Colors.white,
                          alignment: Alignment.center,
                          // padding: EdgeInsets.symmetric(vertical: 8),
                          child: Icon(
                            Icons.download_outlined,
                            color: Colors.black87,
                          ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.white,
                        elevation: 0
                      ) ,
                      onPressed: () {},
                      child: Container(
                          color: Colors.white,
                          alignment: Alignment.center,
                          // padding: EdgeInsets.symmetric(vertical: 8),
                          child: Icon(
                            Icons.forward_outlined,
                            color: Colors.black87,
                          ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
