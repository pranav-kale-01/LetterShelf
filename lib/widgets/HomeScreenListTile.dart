import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:googleapis/gmail/v1.dart' as gmail;
import 'package:hive/hive.dart';
import 'package:letter_shelf/models/emailMessage.dart';
import 'package:http/http.dart' as http;
import 'package:letter_shelf/widgets/HomeScreenBottomDialog.dart';

import '../firebase_operations/storage_service.dart';
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
  Storage storage = Storage();
  Color backgroundColor = Colors.pinkAccent;
  String circleAvatarText = "";
  bool executeOnTap = true;
  bool tileIsSelected = false;
  Image? image;

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

  late bool stopImageLoading = false;
  late BuildContext ctx;

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

    // getting background image for the tile
    getBackgroundImage();
  }

  Future<void> getBackgroundImage() async {
    // checking if showing images option is disabled in preferences
    // opening user's newsletters list file
    String path = ( await Utils.localPath ).path;
    String username = Utils.username;

    File file = File( '$path/preferences_' + username + '.json');
    file.createSync();
    String data = file.readAsStringSync();
    Map<String, dynamic> jsonData = {};

    if( data.isEmpty ) {
      jsonData['show_images_on_tile'] = true;
      file.writeAsString( jsonEncode(jsonData)) ;
      return;
    }

    jsonData = jsonDecode( data );
    if( jsonData['show_images_on_tile'] == false ) {
      return;
    }

    bool loadFromCache = true;

    if( !Utils.firstScreenLoad(widget.emailMessage.from + "CachedImage" ) ) {
      // if it's that the image is being loaded since the start of the app, we will load the image from api
      loadFromCache = false;
    }

    if (loadFromCache) {
      if( !stopImageLoading ) {
          List<dynamic> tempList = await hiveService.getBoxes( widget.emailMessage.from + "CachedImage");
          Uint8List rawImage = Uint8List.fromList(List<int>.from(tempList));
          image = Image.memory(rawImage);

          setState(() { });
      }

    }
    else {
      Future.delayed(const Duration( seconds: 1), () async {
        List<String> fileNames = await storage.listLogosFile( widget.emailMessage.from);

        if( fileNames.isNotEmpty) {
          try {
            String url = await storage.getDownloadUrl( fileNames[0] );
            http.Response response = await http.get( Uri.parse( url) );

            Box _box = await Hive.openBox( widget.emailMessage.from + "CachedImage" );
            _box.deleteAll(_box.keys);

            await hiveService.addBoxes(  response.bodyBytes, widget.emailMessage.from + "CachedImage");
            Utils.firstScreenLoad(widget.emailMessage.from + "CachedImage", true);

            setState(() => image = Image.network(
              url,
              fit: BoxFit.cover,
            ));
          }
          catch( e, stackTrace ) {
            debugPrint( e.toString() );
            debugPrint( stackTrace.toString() );
          }
        }
      });
    }
  }
  

  @override
  Widget build(BuildContext context) {
    ctx = context;

    return SizedBox(
      height: 150,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        color: Colors.white,
        child: InkWell(
          onLongPress: () {
            setState(() {
              tileIsSelected = true;
            });

            var topPadding =MediaQueryData.fromWindow(window).padding.top;

            showDialog(
                context: context,
                builder: (context) => HomeScreenBottomDialog(
                    topPadding: topPadding,
                    hiveServices: hiveService,
                    emailMessage: widget.emailMessage,
                    username: widget.username,
                    gmailApi: widget.gmailApi,
                ),
            ).then((val) => setState( () => tileIsSelected = false ) );
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: tileIsSelected ? const Color(0xffa2d7ff) : Colors.transparent,
            ),
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
                          padding: const EdgeInsets.only(left: 4, right: 4, top: 15),
                          child: image == null ? CircleAvatar(
                            backgroundColor: backgroundColor,
                            radius: 32,
                            child: Text(
                                circleAvatarText,
                                style: const TextStyle(
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
                                  style: const TextStyle(
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
                  margin: const EdgeInsets.only(top: 8, left: 6, right: 6),
                  color: Colors.black12,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    stopImageLoading = true;

    super.dispose();
  }
}
