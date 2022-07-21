import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

import 'package:letter_shelf/models/emailMessage.dart';
import 'package:letter_shelf/utils/hive_services.dart';

import 'package:googleapis/gmail/v1.dart' as gmail;

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
  ScrollController scrollController = ScrollController(initialScrollOffset: 1);
  ScrollController innerScrollController = ScrollController();
  Radius bottomDialogBorderRadius = const Radius.circular(15);
  bool positionNotZero = true;

  double? screenHeight;
  bool isNeverScrollableScrollPhysics = false;
  ScrollPhysics? innerScrollPhysics = const NeverScrollableScrollPhysics();
  ScrollPosition? scrollPosition;

  bool isAnimating = false;

  @override
  Widget build(BuildContext context) {
    // adding listener to scroll Controller
    scrollController.addListener(() async {
      // breaking the operation if the the scroll view is currently animating
      if( isAnimating ) {
        return;
      }

      scrollPosition ??= scrollController.positions.toList()[0];
      screenHeight ??= MediaQuery.of(context).size.height;

      // checking scroll direction
      if( scrollController.position.userScrollDirection == ScrollDirection.forward) {
        // if the bottom sheet is at the lowest position and user scrolls down, then the bottom sheet will animate down and then close
        if( scrollController.position.pixels == 0.0 ) {
          try {
            isAnimating = true;

            SchedulerBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pop();
            });
          }
          catch( e ) {
            debugPrint( e.toString());
          }
          return;
        }
        else {
          isAnimating = true;

          await scrollController.animateTo(
            1.0,
            curve: Curves.linear,
            duration: const Duration( milliseconds: 250 ),
          ).then( (_) {
            isAnimating = false;
          });
        }
      }
      else if(  scrollController.position.userScrollDirection == ScrollDirection.reverse  ) {
        // if the bottom sheet is at the the bottom and user scrolls upwards then, animating up till the bottom sheet covers the whole page
        isAnimating = true;

        await scrollController.animateTo(
          screenHeight! * 0.6,
          curve: Curves.linear,
          duration: const Duration( milliseconds: 250 ),
        ).then( (_) {
          isAnimating = false;
        });
      }

      // if the bottom sheet covers up the whole screen, then we will replace the circular border with sharp borders
      if( scrollController.position.pixels == scrollController.position.maxScrollExtent && ( screenHeight! * 0.6 ).round() == scrollPosition!.maxScrollExtent.round() ) {

        positionNotZero = true;
        innerScrollController.jumpTo( 1.0 );

        isNeverScrollableScrollPhysics = true;
        innerScrollPhysics = const ClampingScrollPhysics();

        setState(() {
          bottomDialogBorderRadius = Radius.zero;
        });
      }
      else if(positionNotZero){
        positionNotZero = false;

        isNeverScrollableScrollPhysics = false;
        innerScrollPhysics = const NeverScrollableScrollPhysics();

        setState(() {
          bottomDialogBorderRadius = const Radius.circular(15);
        });
      }
    });

    if( innerScrollController.hasClients ) {
      // scroll Controller for inner SingleChildScrollView
      innerScrollController.addListener(() async {
        scrollPosition ??= scrollController.positions.toList()[0];
        screenHeight ??= MediaQuery.of(context).size.height;

        if( innerScrollController.offset == 0.0 ) {
          await scrollController.animateTo(
            (scrollPosition!.maxScrollExtent.round() - screenHeight! * 0.6) + 1,
            duration: const Duration( milliseconds: 250),
            curve: Curves.linear,
          );
        }
      });
    }

    return Dialog(
        insetPadding: EdgeInsets.zero,
        alignment: Alignment.bottomCenter,
        backgroundColor: Colors.transparent,
        elevation: 0,

        child: SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: NotificationListener<OverscrollIndicatorNotification>(
              onNotification: (OverscrollIndicatorNotification overScroll) {
                overScroll.disallowIndicator();
                return false;
              },
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: ( ) => Navigator.of(context).pop(),
                      child: Container(
                          height: MediaQuery.of(context).size.height * 0.6,
                          color: Colors.transparent,
                        ),
                    ),
                    Container(
                      constraints: BoxConstraints(
                        minHeight: ( MediaQuery.of(context).size.height * 0.4 - widget.topPadding ) + 1,
                      ),
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height - widget.topPadding,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.vertical(
                            top: bottomDialogBorderRadius,
                          ),
                          color: Colors.white,
                        ),
                        child: Container(
                          margin: const EdgeInsets.only(top: 10.0),
                          child: NotificationListener<OverscrollIndicatorNotification>(
                            onNotification: (OverscrollIndicatorNotification overScroll) {
                              overScroll.disallowIndicator();
                              return false;
                            },
                            child: SingleChildScrollView(
                              physics: innerScrollPhysics,
                              controller: innerScrollController,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
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
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
        )
    );
  }
}