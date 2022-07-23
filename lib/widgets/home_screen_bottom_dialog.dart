import 'package:flutter/material.dart';

import 'package:letter_shelf/models/emailMessage.dart';
import 'package:letter_shelf/utils/hive_services.dart';

import 'package:googleapis/gmail/v1.dart' as gmail;
import 'package:letter_shelf/widgets/bottom_popup_dialog.dart';

class HomeScreenBottomDialog extends StatefulWidget {
  final gmail.GmailApi gmailApi;
  final double topPadding;
  final HiveServices hiveServices;
  final EmailMessage emailMessage;
  final String username;

  const HomeScreenBottomDialog({
    Key? key,
    required this.gmailApi,
    required this.topPadding,
    required this.hiveServices,
    required this.emailMessage,
    required this.username}) : super(key: key);

  @override
  _HomeScreenBottomDialogState createState() => _HomeScreenBottomDialogState();
}

class _HomeScreenBottomDialogState extends State<HomeScreenBottomDialog> {
  @override
  Widget build(BuildContext context) {
    return BottomPopupDialog(
      child: Column(
        children: [
        TextButton(
          onPressed: () async {
            List<dynamic> tempList = await widget.hiveServices.getBoxes( " is:starred CachedMessages" + widget.username );

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

                widget.hiveServices.addBoxes( tempList, " is:starred CachedMessages" + widget.username );

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

                widget.hiveServices.addBoxes( tempList, " is:starred CachedMessages" + widget.username );
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
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.symmetric( vertical: 4.0, horizontal: 12.0 ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  alignment: Alignment.center,
                  child: Icon(
                    widget.emailMessage.starred ? Icons.star : Icons.star_border,
                    color: widget.emailMessage.starred ? Colors.amber : Colors.black,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(left: 8.0),
                  alignment: Alignment.center,
                  child: Text(
                    widget.emailMessage.starred ? "Remove From Starred" : "Mark as Starred",
                    style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.normal
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        TextButton(
          onPressed: () async {
            List<dynamic> tempList = await widget.hiveServices.getBoxes( " is:important CachedMessages" + widget.username );

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

              widget.hiveServices.addBoxes( tempList, " is:important CachedMessages" + widget.username );


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

              widget.hiveServices.addBoxes( tempList, " is:important CachedMessages" + widget.username );


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
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.symmetric( vertical: 4.0, horizontal: 12.0 ),
            child: Row(
              children: [
                Container(
                  alignment: Alignment.center,
                  child: Icon(
                    widget.emailMessage.important ? Icons.label_important : Icons.label_important_outline,
                    color: widget.emailMessage.important ? Colors.redAccent : Colors.black,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(left: 8.0),
                  alignment: Alignment.center,
                  child: Text(
                    widget.emailMessage.important ? "Remove From Important" : "Mark as Important",
                    style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.normal
                    ),
                  ),
                )
              ],
            ),
          ),
        ),

        // TODO: add logic for locally saving newsletters
        // TextButton(
        //   onPressed: () async {
        //
        //   },
        //   child: Container(
        //     width: MediaQuery.of(context).size.width,
        //     padding: const EdgeInsets.symmetric( vertical: 4.0, horizontal: 12.0 ),
        //     child: Row(
        //       children: [
        //         Container(
        //           alignment: Alignment.center,
        //           child: const Icon(
        //             Icons.download_outlined,
        //             color: Colors.black,
        //           ),
        //         ),
        //         Container(
        //             padding: const EdgeInsets.only(left: 8.0),
        //             alignment: Alignment.center,
        //             child: const Text(
        //                 "Save newsletter",
        //                 style: TextStyle(
        //                   color: Colors.black,
        //                   fontWeight: FontWeight.normal
        //                 ),
        //             ),
        //         )
        //       ],
        //     ),
        //   ),
        // ),
        ],
      ),
    );
  }
}