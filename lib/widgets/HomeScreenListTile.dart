import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/gmail/v1.dart' as gmail;
import 'package:hive/hive.dart';
import 'package:letter_shelf/models/emailMessage.dart';
import 'package:http/http.dart' as http;

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
  String circleAvatarText = "";
  bool executeOnTap = true;
  late BuildContext ctx;
  Image? image;
  late bool stopImageLoading = false;
  Storage storage = Storage();
  Color backgroundColor = Colors.pinkAccent;
  bool tileIsSelected = false;

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

            Rect? cutoutBounds;

            List<DisplayFeature> features = MediaQuery.of(context).displayFeatures;

            for(DisplayFeature feature in features ) {
              if( feature.type == DisplayFeatureType.cutout ) {
                cutoutBounds = feature.bounds;
              }

              debugPrint( feature.toString() );
            }

            debugPrint( MediaQuery.of(context).viewPadding.top.toString() );
            debugPrint( MediaQuery.of(context).viewInsets.top.toString() );
            var topPadding =MediaQueryData.fromWindow(window).padding.top;

            showDialog(
                context: context,
                builder: (context) => Dialog(
                  insetPadding: EdgeInsets.zero,
                  alignment: Alignment.bottomCenter,
                  backgroundColor: Colors.transparent,
                  elevation: 0,

                  child: SizedBox(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: ( ) => Navigator.of(context).pop(),
                            child: Container(
                              height: MediaQuery.of(context).size.height * 0.6,
                              color: Colors.transparent,
                            ),
                          ),
                          Container(
                            height: MediaQuery.of(context).size.height - topPadding,
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(15),
                              ),
                              color: Colors.white,
                            ),
                            child: Container(
                              margin: const EdgeInsets.only(top: 10.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    padding: EdgeInsets.symmetric( vertical: 2.0 ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              primary: Colors.white,
                                              elevation: 0
                                          ) ,
                                          onPressed: () async {
                                            List<dynamic> tempList = await hiveService.getBoxes( " is:starred CachedMessages" + widget.username );

                                            if (  widget.emailMessage.starred ) {
                                              setState(() {
                                                widget.emailMessage.starred = false;

                                                // now inserting new data to previous cached data
                                                for( var msg in tempList ) {
                                                  if( msg['msgId'] == widget.emailMessage.msgId ) {
                                                    msg['starred'] = false;
                                                    break;
                                                  }
                                                }

                                                hiveService.addBoxes( tempList, " is:starred CachedMessages" + widget.username );

                                                // modifying the messages label to remove UNREAD Label from the message
                                                gmail.ModifyMessageRequest req = gmail.ModifyMessageRequest(
                                                    removeLabelIds: [
                                                      "STARRED"
                                                    ]
                                                );

                                                widget.gmailApi.users.messages.modify( req, 'me', widget.emailMessage.msgId );
                                              });
                                            }
                                            else {
                                              setState(() {
                                                widget.emailMessage.starred = true;
                                                // now inserting new data to previous cached data
                                                for( var msg in tempList ) {
                                                  if( msg['msgId'] == widget.emailMessage.msgId ) {
                                                    msg['starred'] = true;
                                                    break;
                                                  }
                                                }

                                                hiveService.addBoxes( tempList, " is:starred CachedMessages" + widget.username );
                                                // modifying the messages label to remove UNREAD Label from the message
                                                gmail.ModifyMessageRequest req = gmail.ModifyMessageRequest(
                                                    addLabelIds: [
                                                      "STARRED"
                                                    ]
                                                );

                                                widget.gmailApi.users.messages.modify( req, 'me', widget.emailMessage.msgId);
                                              });
                                            }
                                          },
                                          child: Container(
                                            color: Colors.white,
                                            alignment: Alignment.center,
                                            // padding: EdgeInsets.symmetric(vertical: 8),
                                            child: Icon(
                                              widget.emailMessage.starred ? Icons.star : Icons.star_border,
                                              color: widget.emailMessage.starred ? Colors.amber : Colors.grey,
                                              size: 28,
                                            ),
                                          ),
                                        ),
                                        Text("Mark as Starred")
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    padding: EdgeInsets.symmetric( vertical: 2.0 ),
                                    child: Row(
                                      children: [
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              primary: Colors.white,
                                              elevation: 0
                                          ) ,
                                          onPressed: () async {
                                            List<dynamic> tempList = await hiveService.getBoxes( " is:important CachedMessages" + widget.username );

                                            if (  widget.emailMessage.important ) {
                                              setState(() {
                                                widget.emailMessage.important = false;
                                              });

                                              // now inserting new data to previous cached data
                                              for( var msg in tempList ) {
                                                if( msg['msgId'] == widget.emailMessage.msgId ) {
                                                  msg['important'] = false;
                                                  break;
                                                }
                                              }

                                              hiveService.addBoxes( tempList, " is:important CachedMessages" + widget.username );


                                              // modifying the messages label to remove UNREAD Label from the message
                                              gmail.ModifyMessageRequest req = gmail.ModifyMessageRequest(
                                                  removeLabelIds: [
                                                    "IMPORTANT"
                                                  ]
                                              );

                                              widget.gmailApi.users.messages.modify( req, 'me', widget.emailMessage.msgId);

                                              setState(() { });
                                            }
                                            else {
                                              setState(() {
                                                widget.emailMessage.important = true;
                                              });

                                              // now inserting new data to previous cached data
                                              for( var msg in tempList ) {
                                                if( msg['msgId'] == widget.emailMessage.msgId ) {
                                                  msg['important'] = true;
                                                  break;
                                                }
                                              }

                                              hiveService.addBoxes( tempList, " is:important CachedMessages" + widget.username );


                                              // modifying the messages label to remove UNREAD Label from the message
                                              gmail.ModifyMessageRequest req = gmail.ModifyMessageRequest(
                                                  addLabelIds: [
                                                    "IMPORTANT"
                                                  ]
                                              );

                                              widget.gmailApi.users.messages.modify( req, 'me', widget.emailMessage.msgId);

                                              setState(() {

                                              });
                                            }
                                          },
                                          child: Container(
                                            color: Colors.white,
                                            alignment: Alignment.center,
                                            // padding: EdgeInsets.symmetric(vertical: 8),
                                            child: Icon(
                                              widget.emailMessage.important ? Icons.label_important : Icons.label_important_outline,
                                              color: Colors.redAccent,
                                              size: 28,
                                            ),
                                          ),
                                        ),
                                        Text("Mark as Important")
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    padding: EdgeInsets.symmetric( vertical: 2.0 ),
                                    child: Row(
                                      children: [
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              primary: Colors.white,
                                              elevation: 0
                                          ) ,
                                          onPressed: () async {
                                            List<dynamic> tempList = await hiveService.getBoxes( " is:important CachedMessages" + widget.username );

                                            if (  widget.emailMessage.important ) {
                                              setState(() {
                                                widget.emailMessage.important = false;
                                              });

                                              // now inserting new data to previous cached data
                                              for( var msg in tempList ) {
                                                if( msg['msgId'] == widget.emailMessage.msgId ) {
                                                  msg['important'] = false;
                                                  break;
                                                }
                                              }

                                              hiveService.addBoxes( tempList, " is:important CachedMessages" + widget.username );


                                              // modifying the messages label to remove UNREAD Label from the message
                                              gmail.ModifyMessageRequest req = gmail.ModifyMessageRequest(
                                                  removeLabelIds: [
                                                    "IMPORTANT"
                                                  ]
                                              );

                                              widget.gmailApi.users.messages.modify( req, 'me', widget.emailMessage.msgId);

                                              setState(() { });
                                            }
                                            else {
                                              setState(() {
                                                widget.emailMessage.important = true;
                                              });

                                              // now inserting new data to previous cached data
                                              for( var msg in tempList ) {
                                                if( msg['msgId'] == widget.emailMessage.msgId ) {
                                                  msg['important'] = true;
                                                  break;
                                                }
                                              }

                                              hiveService.addBoxes( tempList, " is:important CachedMessages" + widget.username );


                                              // modifying the messages label to remove UNREAD Label from the message
                                              gmail.ModifyMessageRequest req = gmail.ModifyMessageRequest(
                                                  addLabelIds: [
                                                    "IMPORTANT"
                                                  ]
                                              );

                                              widget.gmailApi.users.messages.modify( req, 'me', widget.emailMessage.msgId);

                                              setState(() {

                                              });
                                            }
                                          },
                                          child: Container(
                                            color: Colors.white,
                                            alignment: Alignment.center,
                                            // padding: EdgeInsets.symmetric(vertical: 8),
                                            child: Icon(
                                              widget.emailMessage.important ? Icons.label_important : Icons.label_important_outline,
                                              color: Colors.redAccent,
                                              size: 28,
                                            ),
                                          ),
                                        ),
                                        Text("Mark as Important")
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    padding: EdgeInsets.symmetric( vertical: 2.0 ),
                                    child: Row(
                                      children: [
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              primary: Colors.white,
                                              elevation: 0
                                          ) ,
                                          onPressed: () async {
                                            List<dynamic> tempList = await hiveService.getBoxes( " is:important CachedMessages" + widget.username );

                                            if (  widget.emailMessage.important ) {
                                              setState(() {
                                                widget.emailMessage.important = false;
                                              });

                                              // now inserting new data to previous cached data
                                              for( var msg in tempList ) {
                                                if( msg['msgId'] == widget.emailMessage.msgId ) {
                                                  msg['important'] = false;
                                                  break;
                                                }
                                              }

                                              hiveService.addBoxes( tempList, " is:important CachedMessages" + widget.username );


                                              // modifying the messages label to remove UNREAD Label from the message
                                              gmail.ModifyMessageRequest req = gmail.ModifyMessageRequest(
                                                  removeLabelIds: [
                                                    "IMPORTANT"
                                                  ]
                                              );

                                              widget.gmailApi.users.messages.modify( req, 'me', widget.emailMessage.msgId);

                                              setState(() { });
                                            }
                                            else {
                                              setState(() {
                                                widget.emailMessage.important = true;
                                              });

                                              // now inserting new data to previous cached data
                                              for( var msg in tempList ) {
                                                if( msg['msgId'] == widget.emailMessage.msgId ) {
                                                  msg['important'] = true;
                                                  break;
                                                }
                                              }

                                              hiveService.addBoxes( tempList, " is:important CachedMessages" + widget.username );


                                              // modifying the messages label to remove UNREAD Label from the message
                                              gmail.ModifyMessageRequest req = gmail.ModifyMessageRequest(
                                                  addLabelIds: [
                                                    "IMPORTANT"
                                                  ]
                                              );

                                              widget.gmailApi.users.messages.modify( req, 'me', widget.emailMessage.msgId);

                                              setState(() {

                                              });
                                            }
                                          },
                                          child: Container(
                                            color: Colors.white,
                                            alignment: Alignment.center,
                                            // padding: EdgeInsets.symmetric(vertical: 8),
                                            child: Icon(
                                              widget.emailMessage.important ? Icons.label_important : Icons.label_important_outline,
                                              color: Colors.redAccent,
                                              size: 28,
                                            ),
                                          ),
                                        ),
                                        Text("Mark as Important")
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    padding: EdgeInsets.symmetric( vertical: 2.0 ),
                                    child: Row(
                                      children: [
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              primary: Colors.white,
                                              elevation: 0
                                          ) ,
                                          onPressed: () async {
                                            List<dynamic> tempList = await hiveService.getBoxes( " is:important CachedMessages" + widget.username );

                                            if (  widget.emailMessage.important ) {
                                              setState(() {
                                                widget.emailMessage.important = false;
                                              });

                                              // now inserting new data to previous cached data
                                              for( var msg in tempList ) {
                                                if( msg['msgId'] == widget.emailMessage.msgId ) {
                                                  msg['important'] = false;
                                                  break;
                                                }
                                              }

                                              hiveService.addBoxes( tempList, " is:important CachedMessages" + widget.username );


                                              // modifying the messages label to remove UNREAD Label from the message
                                              gmail.ModifyMessageRequest req = gmail.ModifyMessageRequest(
                                                  removeLabelIds: [
                                                    "IMPORTANT"
                                                  ]
                                              );

                                              widget.gmailApi.users.messages.modify( req, 'me', widget.emailMessage.msgId);

                                              setState(() { });
                                            }
                                            else {
                                              setState(() {
                                                widget.emailMessage.important = true;
                                              });

                                              // now inserting new data to previous cached data
                                              for( var msg in tempList ) {
                                                if( msg['msgId'] == widget.emailMessage.msgId ) {
                                                  msg['important'] = true;
                                                  break;
                                                }
                                              }

                                              hiveService.addBoxes( tempList, " is:important CachedMessages" + widget.username );


                                              // modifying the messages label to remove UNREAD Label from the message
                                              gmail.ModifyMessageRequest req = gmail.ModifyMessageRequest(
                                                  addLabelIds: [
                                                    "IMPORTANT"
                                                  ]
                                              );

                                              widget.gmailApi.users.messages.modify( req, 'me', widget.emailMessage.msgId);

                                              setState(() {

                                              });
                                            }
                                          },
                                          child: Container(
                                            color: Colors.white,
                                            alignment: Alignment.center,
                                            // padding: EdgeInsets.symmetric(vertical: 8),
                                            child: Icon(
                                              widget.emailMessage.important ? Icons.label_important : Icons.label_important_outline,
                                              color: Colors.redAccent,
                                              size: 28,
                                            ),
                                          ),
                                        ),
                                        Text("Mark as Important")
                                      ],
                                    ),
                                  ),

                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    padding: EdgeInsets.symmetric( vertical: 2.0 ),
                                    child: Row(
                                      children: [
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              primary: Colors.white,
                                              elevation: 0
                                          ) ,
                                          onPressed: () async {
                                            List<dynamic> tempList = await hiveService.getBoxes( " is:important CachedMessages" + widget.username );

                                            if (  widget.emailMessage.important ) {
                                              setState(() {
                                                widget.emailMessage.important = false;
                                              });

                                              // now inserting new data to previous cached data
                                              for( var msg in tempList ) {
                                                if( msg['msgId'] == widget.emailMessage.msgId ) {
                                                  msg['important'] = false;
                                                  break;
                                                }
                                              }

                                              hiveService.addBoxes( tempList, " is:important CachedMessages" + widget.username );


                                              // modifying the messages label to remove UNREAD Label from the message
                                              gmail.ModifyMessageRequest req = gmail.ModifyMessageRequest(
                                                  removeLabelIds: [
                                                    "IMPORTANT"
                                                  ]
                                              );

                                              widget.gmailApi.users.messages.modify( req, 'me', widget.emailMessage.msgId);

                                              setState(() { });
                                            }
                                            else {
                                              setState(() {
                                                widget.emailMessage.important = true;
                                              });

                                              // now inserting new data to previous cached data
                                              for( var msg in tempList ) {
                                                if( msg['msgId'] == widget.emailMessage.msgId ) {
                                                  msg['important'] = true;
                                                  break;
                                                }
                                              }

                                              hiveService.addBoxes( tempList, " is:important CachedMessages" + widget.username );


                                              // modifying the messages label to remove UNREAD Label from the message
                                              gmail.ModifyMessageRequest req = gmail.ModifyMessageRequest(
                                                  addLabelIds: [
                                                    "IMPORTANT"
                                                  ]
                                              );

                                              widget.gmailApi.users.messages.modify( req, 'me', widget.emailMessage.msgId);

                                              setState(() {

                                              });
                                            }
                                          },
                                          child: Container(
                                            color: Colors.white,
                                            alignment: Alignment.center,
                                            // padding: EdgeInsets.symmetric(vertical: 8),
                                            child: Icon(
                                              widget.emailMessage.important ? Icons.label_important : Icons.label_important_outline,
                                              color: Colors.redAccent,
                                              size: 28,
                                            ),
                                          ),
                                        ),
                                        Text("Mark as Important")
                                      ],
                                    ),
                                  ),

                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    padding: EdgeInsets.symmetric( vertical: 2.0 ),
                                    child: Row(
                                      children: [
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              primary: Colors.white,
                                              elevation: 0
                                          ) ,
                                          onPressed: () async {
                                            List<dynamic> tempList = await hiveService.getBoxes( " is:important CachedMessages" + widget.username );

                                            if (  widget.emailMessage.important ) {
                                              setState(() {
                                                widget.emailMessage.important = false;
                                              });

                                              // now inserting new data to previous cached data
                                              for( var msg in tempList ) {
                                                if( msg['msgId'] == widget.emailMessage.msgId ) {
                                                  msg['important'] = false;
                                                  break;
                                                }
                                              }

                                              hiveService.addBoxes( tempList, " is:important CachedMessages" + widget.username );


                                              // modifying the messages label to remove UNREAD Label from the message
                                              gmail.ModifyMessageRequest req = gmail.ModifyMessageRequest(
                                                  removeLabelIds: [
                                                    "IMPORTANT"
                                                  ]
                                              );

                                              widget.gmailApi.users.messages.modify( req, 'me', widget.emailMessage.msgId);

                                              setState(() { });
                                            }
                                            else {
                                              setState(() {
                                                widget.emailMessage.important = true;
                                              });

                                              // now inserting new data to previous cached data
                                              for( var msg in tempList ) {
                                                if( msg['msgId'] == widget.emailMessage.msgId ) {
                                                  msg['important'] = true;
                                                  break;
                                                }
                                              }

                                              hiveService.addBoxes( tempList, " is:important CachedMessages" + widget.username );


                                              // modifying the messages label to remove UNREAD Label from the message
                                              gmail.ModifyMessageRequest req = gmail.ModifyMessageRequest(
                                                  addLabelIds: [
                                                    "IMPORTANT"
                                                  ]
                                              );

                                              widget.gmailApi.users.messages.modify( req, 'me', widget.emailMessage.msgId);

                                              setState(() {

                                              });
                                            }
                                          },
                                          child: Container(
                                            color: Colors.white,
                                            alignment: Alignment.center,
                                            // padding: EdgeInsets.symmetric(vertical: 8),
                                            child: Icon(
                                              widget.emailMessage.important ? Icons.label_important : Icons.label_important_outline,
                                              color: Colors.redAccent,
                                              size: 28,
                                            ),
                                          ),
                                        ),
                                        Text("Mark as Important")
                                      ],
                                    ),
                                  ),

                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    padding: EdgeInsets.symmetric( vertical: 2.0 ),
                                    child: Row(
                                      children: [
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              primary: Colors.white,
                                              elevation: 0
                                          ) ,
                                          onPressed: () async {
                                            List<dynamic> tempList = await hiveService.getBoxes( " is:important CachedMessages" + widget.username );

                                            if (  widget.emailMessage.important ) {
                                              setState(() {
                                                widget.emailMessage.important = false;
                                              });

                                              // now inserting new data to previous cached data
                                              for( var msg in tempList ) {
                                                if( msg['msgId'] == widget.emailMessage.msgId ) {
                                                  msg['important'] = false;
                                                  break;
                                                }
                                              }

                                              hiveService.addBoxes( tempList, " is:important CachedMessages" + widget.username );


                                              // modifying the messages label to remove UNREAD Label from the message
                                              gmail.ModifyMessageRequest req = gmail.ModifyMessageRequest(
                                                  removeLabelIds: [
                                                    "IMPORTANT"
                                                  ]
                                              );

                                              widget.gmailApi.users.messages.modify( req, 'me', widget.emailMessage.msgId);

                                              setState(() { });
                                            }
                                            else {
                                              setState(() {
                                                widget.emailMessage.important = true;
                                              });

                                              // now inserting new data to previous cached data
                                              for( var msg in tempList ) {
                                                if( msg['msgId'] == widget.emailMessage.msgId ) {
                                                  msg['important'] = true;
                                                  break;
                                                }
                                              }

                                              hiveService.addBoxes( tempList, " is:important CachedMessages" + widget.username );


                                              // modifying the messages label to remove UNREAD Label from the message
                                              gmail.ModifyMessageRequest req = gmail.ModifyMessageRequest(
                                                  addLabelIds: [
                                                    "IMPORTANT"
                                                  ]
                                              );

                                              widget.gmailApi.users.messages.modify( req, 'me', widget.emailMessage.msgId);

                                              setState(() {

                                              });
                                            }
                                          },
                                          child: Container(
                                            color: Colors.white,
                                            alignment: Alignment.center,
                                            // padding: EdgeInsets.symmetric(vertical: 8),
                                            child: Icon(
                                              widget.emailMessage.important ? Icons.label_important : Icons.label_important_outline,
                                              color: Colors.redAccent,
                                              size: 28,
                                            ),
                                          ),
                                        ),
                                        Text("Mark as Important")
                                      ],
                                    ),
                                  ),

                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  )
                )
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
