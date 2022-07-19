import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

class HomeScreenBottomDialog extends StatefulWidget {
  final double topPadding;

  const HomeScreenBottomDialog({Key? key, required this.topPadding}) : super(key: key);

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
    // if( scrollController.hasClients ) {
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
          if( scrollController.position.pixels == (scrollPosition!.maxScrollExtent.round() - screenHeight! * 0.6).round()  ) {
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
          // else if( scrollController.position.pixels == 0.0 ) {
          // if the bottom sheet is in fullscreen mode, then animating it to the bottom sheet

          // }
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
    // }

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
                      child: SingleChildScrollView(
                        physics: innerScrollPhysics,
                        controller: innerScrollController,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width,
                              padding: const EdgeInsets.symmetric( vertical: 2.0 ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        primary: Colors.white,
                                        elevation: 0
                                    ) ,
                                    onPressed: () async {
                                      // List<dynamic> tempList = await hiveService.getBoxes( " is:starred CachedMessages" + widget.username );
                                      //
                                      // if (  widget.emailMessage.starred ) {
                                      //   setState(() {
                                      //     widget.emailMessage.starred = false;
                                      //
                                      //     // now inserting new data to previous cached data
                                      //     for( var msg in tempList ) {
                                      //       if( msg['msgId'] == widget.emailMessage.msgId ) {
                                      //         msg['starred'] = false;
                                      //         break;
                                      //       }
                                      //     }
                                      //
                                      //     hiveService.addBoxes( tempList, " is:starred CachedMessages" + widget.username );
                                      //
                                      //     // modifying the messages label to remove UNREAD Label from the message
                                      //     gmail.ModifyMessageRequest req = gmail.ModifyMessageRequest(
                                      //         removeLabelIds: [
                                      //           "STARRED"
                                      //         ]
                                      //     );
                                      //
                                      //     widget.gmailApi.users.messages.modify( req, 'me', widget.emailMessage.msgId );
                                      //   });
                                      // }
                                      // else {
                                        // setState(() {
                                        //   widget.emailMessage.starred = true;
                                        //   // now inserting new data to previous cached data
                                        //   for( var msg in tempList ) {
                                        //     if( msg['msgId'] == widget.emailMessage.msgId ) {
                                        //       msg['starred'] = true;
                                        //       break;
                                        //     }
                                        //   }
                                        //
                                        //   hiveService.addBoxes( tempList, " is:starred CachedMessages" + widget.username );
                                        //   // modifying the messages label to remove UNREAD Label from the message
                                        //   gmail.ModifyMessageRequest req = gmail.ModifyMessageRequest(
                                        //       addLabelIds: [
                                        //         "STARRED"
                                        //       ]
                                        //   );
                                        //
                                        //   widget.gmailApi.users.messages.modify( req, 'me', widget.emailMessage.msgId);
                                        // });
                                      // }
                                    },
                                    child: Container(
                                      color: Colors.white,
                                      alignment: Alignment.center,
                                      // padding: EdgeInsets.symmetric(vertical: 8),
                                      child: const Icon(
                                        Icons.star,
                                        // widget.emailMessage.starred ? Icons.star : Icons.star_border,
                                        color: Colors.grey, // color: widget.emailMessage.starred ? Colors.amber : Colors.grey,
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
                                      // List<dynamic> tempList = await hiveService.getBoxes( " is:important CachedMessages" + widget.username );
                                      //
                                      // if (  widget.emailMessage.important ) {
                                      //   setState(() {
                                      //     widget.emailMessage.important = false;
                                      //   });
                                      //
                                      //   // now inserting new data to previous cached data
                                      //   for( var msg in tempList ) {
                                      //     if( msg['msgId'] == widget.emailMessage.msgId ) {
                                      //       msg['important'] = false;
                                      //       break;
                                      //     }
                                      //   }
                                      //
                                      //   hiveService.addBoxes( tempList, " is:important CachedMessages" + widget.username );
                                      //
                                      //
                                      //   // modifying the messages label to remove UNREAD Label from the message
                                      //   gmail.ModifyMessageRequest req = gmail.ModifyMessageRequest(
                                      //       removeLabelIds: [
                                      //         "IMPORTANT"
                                      //       ]
                                      //   );
                                      //
                                      //   widget.gmailApi.users.messages.modify( req, 'me', widget.emailMessage.msgId);
                                      //
                                      //   setState(() { });
                                      // }
                                      // else {
                                      //   setState(() {
                                      //     widget.emailMessage.important = true;
                                      //   });
                                      //
                                      //   // now inserting new data to previous cached data
                                      //   for( var msg in tempList ) {
                                      //     if( msg['msgId'] == widget.emailMessage.msgId ) {
                                      //       msg['important'] = true;
                                      //       break;
                                      //     }
                                      //   }
                                      //
                                      //   hiveService.addBoxes( tempList, " is:important CachedMessages" + widget.username );
                                      //
                                      //
                                      //   // modifying the messages label to remove UNREAD Label from the message
                                      //   gmail.ModifyMessageRequest req = gmail.ModifyMessageRequest(
                                      //       addLabelIds: [
                                      //         "IMPORTANT"
                                      //       ]
                                      //   );
                                      //
                                      //   widget.gmailApi.users.messages.modify( req, 'me', widget.emailMessage.msgId);
                                      //
                                      //   setState(() {
                                      //
                                      //   });
                                      // }
                                    },
                                    child: Container(
                                      color: Colors.white,
                                      alignment: Alignment.center,
                                      // padding: EdgeInsets.symmetric(vertical: 8),
                                      child: const Icon(
                                        Icons.label_important,
                                        // widget.emailMessage.important ? Icons.label_important : Icons.label_important_outline,
                                        color: Colors.redAccent,
                                        size: 28,
                                      ),
                                    ),
                                  ),
                                  Text("Mark as Important")
                                ],
                              ),
                            ),

                            // temp
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
                                      // List<dynamic> tempList = await hiveService.getBoxes( " is:important CachedMessages" + widget.username );
                                      //
                                      // if (  widget.emailMessage.important ) {
                                      //   setState(() {
                                      //     widget.emailMessage.important = false;
                                      //   });
                                      //
                                      //   // now inserting new data to previous cached data
                                      //   for( var msg in tempList ) {
                                      //     if( msg['msgId'] == widget.emailMessage.msgId ) {
                                      //       msg['important'] = false;
                                      //       break;
                                      //     }
                                      //   }
                                      //
                                      //   hiveService.addBoxes( tempList, " is:important CachedMessages" + widget.username );
                                      //
                                      //
                                      //   // modifying the messages label to remove UNREAD Label from the message
                                      //   gmail.ModifyMessageRequest req = gmail.ModifyMessageRequest(
                                      //       removeLabelIds: [
                                      //         "IMPORTANT"
                                      //       ]
                                      //   );
                                      //
                                      //   widget.gmailApi.users.messages.modify( req, 'me', widget.emailMessage.msgId);
                                      //
                                      //   setState(() { });
                                      // }
                                      // else {
                                      //   setState(() {
                                      //     widget.emailMessage.important = true;
                                      //   });
                                      //
                                      //   // now inserting new data to previous cached data
                                      //   for( var msg in tempList ) {
                                      //     if( msg['msgId'] == widget.emailMessage.msgId ) {
                                      //       msg['important'] = true;
                                      //       break;
                                      //     }
                                      //   }
                                      //
                                      //   hiveService.addBoxes( tempList, " is:important CachedMessages" + widget.username );
                                      //
                                      //
                                      //   // modifying the messages label to remove UNREAD Label from the message
                                      //   gmail.ModifyMessageRequest req = gmail.ModifyMessageRequest(
                                      //       addLabelIds: [
                                      //         "IMPORTANT"
                                      //       ]
                                      //   );
                                      //
                                      //   widget.gmailApi.users.messages.modify( req, 'me', widget.emailMessage.msgId);
                                      //
                                      //   setState(() {
                                      //
                                      //   });
                                      // }
                                    },
                                    child: Container(
                                      color: Colors.white,
                                      alignment: Alignment.center,
                                      // padding: EdgeInsets.symmetric(vertical: 8),
                                      child: Icon(
                                        Icons.label_important,
                                        // widget.emailMessage.important ? Icons.label_important : Icons.label_important_outline,
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
                                      // List<dynamic> tempList = await hiveService.getBoxes( " is:important CachedMessages" + widget.username );
                                      //
                                      // if (  widget.emailMessage.important ) {
                                      //   setState(() {
                                      //     widget.emailMessage.important = false;
                                      //   });
                                      //
                                      //   // now inserting new data to previous cached data
                                      //   for( var msg in tempList ) {
                                      //     if( msg['msgId'] == widget.emailMessage.msgId ) {
                                      //       msg['important'] = false;
                                      //       break;
                                      //     }
                                      //   }
                                      //
                                      //   hiveService.addBoxes( tempList, " is:important CachedMessages" + widget.username );
                                      //
                                      //
                                      //   // modifying the messages label to remove UNREAD Label from the message
                                      //   gmail.ModifyMessageRequest req = gmail.ModifyMessageRequest(
                                      //       removeLabelIds: [
                                      //         "IMPORTANT"
                                      //       ]
                                      //   );
                                      //
                                      //   widget.gmailApi.users.messages.modify( req, 'me', widget.emailMessage.msgId);
                                      //
                                      //   setState(() { });
                                      // }
                                      // else {
                                      //   setState(() {
                                      //     widget.emailMessage.important = true;
                                      //   });
                                      //
                                      //   // now inserting new data to previous cached data
                                      //   for( var msg in tempList ) {
                                      //     if( msg['msgId'] == widget.emailMessage.msgId ) {
                                      //       msg['important'] = true;
                                      //       break;
                                      //     }
                                      //   }
                                      //
                                      //   hiveService.addBoxes( tempList, " is:important CachedMessages" + widget.username );
                                      //
                                      //
                                      //   // modifying the messages label to remove UNREAD Label from the message
                                      //   gmail.ModifyMessageRequest req = gmail.ModifyMessageRequest(
                                      //       addLabelIds: [
                                      //         "IMPORTANT"
                                      //       ]
                                      //   );
                                      //
                                      //   widget.gmailApi.users.messages.modify( req, 'me', widget.emailMessage.msgId);
                                      //
                                      //   setState(() {
                                      //
                                      //   });
                                      // }
                                    },
                                    child: Container(
                                      color: Colors.white,
                                      alignment: Alignment.center,
                                      // padding: EdgeInsets.symmetric(vertical: 8),
                                      child: Icon(
                                        Icons.label_important,
                                        // widget.emailMessage.important ? Icons.label_important : Icons.label_important_outline,
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
                                      // List<dynamic> tempList = await hiveService.getBoxes( " is:important CachedMessages" + widget.username );
                                      //
                                      // if (  widget.emailMessage.important ) {
                                      //   setState(() {
                                      //     widget.emailMessage.important = false;
                                      //   });
                                      //
                                      //   // now inserting new data to previous cached data
                                      //   for( var msg in tempList ) {
                                      //     if( msg['msgId'] == widget.emailMessage.msgId ) {
                                      //       msg['important'] = false;
                                      //       break;
                                      //     }
                                      //   }
                                      //
                                      //   hiveService.addBoxes( tempList, " is:important CachedMessages" + widget.username );
                                      //
                                      //
                                      //   // modifying the messages label to remove UNREAD Label from the message
                                      //   gmail.ModifyMessageRequest req = gmail.ModifyMessageRequest(
                                      //       removeLabelIds: [
                                      //         "IMPORTANT"
                                      //       ]
                                      //   );
                                      //
                                      //   widget.gmailApi.users.messages.modify( req, 'me', widget.emailMessage.msgId);
                                      //
                                      //   setState(() { });
                                      // }
                                      // else {
                                      //   setState(() {
                                      //     widget.emailMessage.important = true;
                                      //   });
                                      //
                                      //   // now inserting new data to previous cached data
                                      //   for( var msg in tempList ) {
                                      //     if( msg['msgId'] == widget.emailMessage.msgId ) {
                                      //       msg['important'] = true;
                                      //       break;
                                      //     }
                                      //   }
                                      //
                                      //   hiveService.addBoxes( tempList, " is:important CachedMessages" + widget.username );
                                      //
                                      //
                                      //   // modifying the messages label to remove UNREAD Label from the message
                                      //   gmail.ModifyMessageRequest req = gmail.ModifyMessageRequest(
                                      //       addLabelIds: [
                                      //         "IMPORTANT"
                                      //       ]
                                      //   );
                                      //
                                      //   widget.gmailApi.users.messages.modify( req, 'me', widget.emailMessage.msgId);
                                      //
                                      //   setState(() {
                                      //
                                      //   });
                                      // }
                                    },
                                    child: Container(
                                      color: Colors.white,
                                      alignment: Alignment.center,
                                      // padding: EdgeInsets.symmetric(vertical: 8),
                                      child: Icon(
                                        Icons.label_important,
                                        // widget.emailMessage.important ? Icons.label_important : Icons.label_important_outline,
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
                                      // List<dynamic> tempList = await hiveService.getBoxes( " is:important CachedMessages" + widget.username );
                                      //
                                      // if (  widget.emailMessage.important ) {
                                      //   setState(() {
                                      //     widget.emailMessage.important = false;
                                      //   });
                                      //
                                      //   // now inserting new data to previous cached data
                                      //   for( var msg in tempList ) {
                                      //     if( msg['msgId'] == widget.emailMessage.msgId ) {
                                      //       msg['important'] = false;
                                      //       break;
                                      //     }
                                      //   }
                                      //
                                      //   hiveService.addBoxes( tempList, " is:important CachedMessages" + widget.username );
                                      //
                                      //
                                      //   // modifying the messages label to remove UNREAD Label from the message
                                      //   gmail.ModifyMessageRequest req = gmail.ModifyMessageRequest(
                                      //       removeLabelIds: [
                                      //         "IMPORTANT"
                                      //       ]
                                      //   );
                                      //
                                      //   widget.gmailApi.users.messages.modify( req, 'me', widget.emailMessage.msgId);
                                      //
                                      //   setState(() { });
                                      // }
                                      // else {
                                      //   setState(() {
                                      //     widget.emailMessage.important = true;
                                      //   });
                                      //
                                      //   // now inserting new data to previous cached data
                                      //   for( var msg in tempList ) {
                                      //     if( msg['msgId'] == widget.emailMessage.msgId ) {
                                      //       msg['important'] = true;
                                      //       break;
                                      //     }
                                      //   }
                                      //
                                      //   hiveService.addBoxes( tempList, " is:important CachedMessages" + widget.username );
                                      //
                                      //
                                      //   // modifying the messages label to remove UNREAD Label from the message
                                      //   gmail.ModifyMessageRequest req = gmail.ModifyMessageRequest(
                                      //       addLabelIds: [
                                      //         "IMPORTANT"
                                      //       ]
                                      //   );
                                      //
                                      //   widget.gmailApi.users.messages.modify( req, 'me', widget.emailMessage.msgId);
                                      //
                                      //   setState(() {
                                      //
                                      //   });
                                      // }
                                    },
                                    child: Container(
                                      color: Colors.white,
                                      alignment: Alignment.center,
                                      // padding: EdgeInsets.symmetric(vertical: 8),
                                      child: Icon(
                                        Icons.label_important,
                                        // widget.emailMessage.important ? Icons.label_important : Icons.label_important_outline,
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
                                      // List<dynamic> tempList = await hiveService.getBoxes( " is:important CachedMessages" + widget.username );
                                      //
                                      // if (  widget.emailMessage.important ) {
                                      //   setState(() {
                                      //     widget.emailMessage.important = false;
                                      //   });
                                      //
                                      //   // now inserting new data to previous cached data
                                      //   for( var msg in tempList ) {
                                      //     if( msg['msgId'] == widget.emailMessage.msgId ) {
                                      //       msg['important'] = false;
                                      //       break;
                                      //     }
                                      //   }
                                      //
                                      //   hiveService.addBoxes( tempList, " is:important CachedMessages" + widget.username );
                                      //
                                      //
                                      //   // modifying the messages label to remove UNREAD Label from the message
                                      //   gmail.ModifyMessageRequest req = gmail.ModifyMessageRequest(
                                      //       removeLabelIds: [
                                      //         "IMPORTANT"
                                      //       ]
                                      //   );
                                      //
                                      //   widget.gmailApi.users.messages.modify( req, 'me', widget.emailMessage.msgId);
                                      //
                                      //   setState(() { });
                                      // }
                                      // else {
                                      //   setState(() {
                                      //     widget.emailMessage.important = true;
                                      //   });
                                      //
                                      //   // now inserting new data to previous cached data
                                      //   for( var msg in tempList ) {
                                      //     if( msg['msgId'] == widget.emailMessage.msgId ) {
                                      //       msg['important'] = true;
                                      //       break;
                                      //     }
                                      //   }
                                      //
                                      //   hiveService.addBoxes( tempList, " is:important CachedMessages" + widget.username );
                                      //
                                      //
                                      //   // modifying the messages label to remove UNREAD Label from the message
                                      //   gmail.ModifyMessageRequest req = gmail.ModifyMessageRequest(
                                      //       addLabelIds: [
                                      //         "IMPORTANT"
                                      //       ]
                                      //   );
                                      //
                                      //   widget.gmailApi.users.messages.modify( req, 'me', widget.emailMessage.msgId);
                                      //
                                      //   setState(() {
                                      //
                                      //   });
                                      // }
                                    },
                                    child: Container(
                                      color: Colors.white,
                                      alignment: Alignment.center,
                                      // padding: EdgeInsets.symmetric(vertical: 8),
                                      child: Icon(
                                        Icons.label_important,
                                        // widget.emailMessage.important ? Icons.label_important : Icons.label_important_outline,
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
                                      // List<dynamic> tempList = await hiveService.getBoxes( " is:important CachedMessages" + widget.username );
                                      //
                                      // if (  widget.emailMessage.important ) {
                                      //   setState(() {
                                      //     widget.emailMessage.important = false;
                                      //   });
                                      //
                                      //   // now inserting new data to previous cached data
                                      //   for( var msg in tempList ) {
                                      //     if( msg['msgId'] == widget.emailMessage.msgId ) {
                                      //       msg['important'] = false;
                                      //       break;
                                      //     }
                                      //   }
                                      //
                                      //   hiveService.addBoxes( tempList, " is:important CachedMessages" + widget.username );
                                      //
                                      //
                                      //   // modifying the messages label to remove UNREAD Label from the message
                                      //   gmail.ModifyMessageRequest req = gmail.ModifyMessageRequest(
                                      //       removeLabelIds: [
                                      //         "IMPORTANT"
                                      //       ]
                                      //   );
                                      //
                                      //   widget.gmailApi.users.messages.modify( req, 'me', widget.emailMessage.msgId);
                                      //
                                      //   setState(() { });
                                      // }
                                      // else {
                                      //   setState(() {
                                      //     widget.emailMessage.important = true;
                                      //   });
                                      //
                                      //   // now inserting new data to previous cached data
                                      //   for( var msg in tempList ) {
                                      //     if( msg['msgId'] == widget.emailMessage.msgId ) {
                                      //       msg['important'] = true;
                                      //       break;
                                      //     }
                                      //   }
                                      //
                                      //   hiveService.addBoxes( tempList, " is:important CachedMessages" + widget.username );
                                      //
                                      //
                                      //   // modifying the messages label to remove UNREAD Label from the message
                                      //   gmail.ModifyMessageRequest req = gmail.ModifyMessageRequest(
                                      //       addLabelIds: [
                                      //         "IMPORTANT"
                                      //       ]
                                      //   );
                                      //
                                      //   widget.gmailApi.users.messages.modify( req, 'me', widget.emailMessage.msgId);
                                      //
                                      //   setState(() {
                                      //
                                      //   });
                                      // }
                                    },
                                    child: Container(
                                      color: Colors.white,
                                      alignment: Alignment.center,
                                      // padding: EdgeInsets.symmetric(vertical: 8),
                                      child: Icon(
                                        Icons.label_important,
                                        // widget.emailMessage.important ? Icons.label_important : Icons.label_important_outline,
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
                                      // List<dynamic> tempList = await hiveService.getBoxes( " is:important CachedMessages" + widget.username );
                                      //
                                      // if (  widget.emailMessage.important ) {
                                      //   setState(() {
                                      //     widget.emailMessage.important = false;
                                      //   });
                                      //
                                      //   // now inserting new data to previous cached data
                                      //   for( var msg in tempList ) {
                                      //     if( msg['msgId'] == widget.emailMessage.msgId ) {
                                      //       msg['important'] = false;
                                      //       break;
                                      //     }
                                      //   }
                                      //
                                      //   hiveService.addBoxes( tempList, " is:important CachedMessages" + widget.username );
                                      //
                                      //
                                      //   // modifying the messages label to remove UNREAD Label from the message
                                      //   gmail.ModifyMessageRequest req = gmail.ModifyMessageRequest(
                                      //       removeLabelIds: [
                                      //         "IMPORTANT"
                                      //       ]
                                      //   );
                                      //
                                      //   widget.gmailApi.users.messages.modify( req, 'me', widget.emailMessage.msgId);
                                      //
                                      //   setState(() { });
                                      // }
                                      // else {
                                      //   setState(() {
                                      //     widget.emailMessage.important = true;
                                      //   });
                                      //
                                      //   // now inserting new data to previous cached data
                                      //   for( var msg in tempList ) {
                                      //     if( msg['msgId'] == widget.emailMessage.msgId ) {
                                      //       msg['important'] = true;
                                      //       break;
                                      //     }
                                      //   }
                                      //
                                      //   hiveService.addBoxes( tempList, " is:important CachedMessages" + widget.username );
                                      //
                                      //
                                      //   // modifying the messages label to remove UNREAD Label from the message
                                      //   gmail.ModifyMessageRequest req = gmail.ModifyMessageRequest(
                                      //       addLabelIds: [
                                      //         "IMPORTANT"
                                      //       ]
                                      //   );
                                      //
                                      //   widget.gmailApi.users.messages.modify( req, 'me', widget.emailMessage.msgId);
                                      //
                                      //   setState(() {
                                      //
                                      //   });
                                      // }
                                    },
                                    child: Container(
                                      color: Colors.white,
                                      alignment: Alignment.center,
                                      // padding: EdgeInsets.symmetric(vertical: 8),
                                      child: Icon(
                                        Icons.label_important,
                                        // widget.emailMessage.important ? Icons.label_important : Icons.label_important_outline,
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
                                      // List<dynamic> tempList = await hiveService.getBoxes( " is:important CachedMessages" + widget.username );
                                      //
                                      // if (  widget.emailMessage.important ) {
                                      //   setState(() {
                                      //     widget.emailMessage.important = false;
                                      //   });
                                      //
                                      //   // now inserting new data to previous cached data
                                      //   for( var msg in tempList ) {
                                      //     if( msg['msgId'] == widget.emailMessage.msgId ) {
                                      //       msg['important'] = false;
                                      //       break;
                                      //     }
                                      //   }
                                      //
                                      //   hiveService.addBoxes( tempList, " is:important CachedMessages" + widget.username );
                                      //
                                      //
                                      //   // modifying the messages label to remove UNREAD Label from the message
                                      //   gmail.ModifyMessageRequest req = gmail.ModifyMessageRequest(
                                      //       removeLabelIds: [
                                      //         "IMPORTANT"
                                      //       ]
                                      //   );
                                      //
                                      //   widget.gmailApi.users.messages.modify( req, 'me', widget.emailMessage.msgId);
                                      //
                                      //   setState(() { });
                                      // }
                                      // else {
                                      //   setState(() {
                                      //     widget.emailMessage.important = true;
                                      //   });
                                      //
                                      //   // now inserting new data to previous cached data
                                      //   for( var msg in tempList ) {
                                      //     if( msg['msgId'] == widget.emailMessage.msgId ) {
                                      //       msg['important'] = true;
                                      //       break;
                                      //     }
                                      //   }
                                      //
                                      //   hiveService.addBoxes( tempList, " is:important CachedMessages" + widget.username );
                                      //
                                      //
                                      //   // modifying the messages label to remove UNREAD Label from the message
                                      //   gmail.ModifyMessageRequest req = gmail.ModifyMessageRequest(
                                      //       addLabelIds: [
                                      //         "IMPORTANT"
                                      //       ]
                                      //   );
                                      //
                                      //   widget.gmailApi.users.messages.modify( req, 'me', widget.emailMessage.msgId);
                                      //
                                      //   setState(() {
                                      //
                                      //   });
                                      // }
                                    },
                                    child: Container(
                                      color: Colors.white,
                                      alignment: Alignment.center,
                                      // padding: EdgeInsets.symmetric(vertical: 8),
                                      child: Icon(
                                        Icons.label_important,
                                        // widget.emailMessage.important ? Icons.label_important : Icons.label_important_outline,
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
                                      // List<dynamic> tempList = await hiveService.getBoxes( " is:important CachedMessages" + widget.username );
                                      //
                                      // if (  widget.emailMessage.important ) {
                                      //   setState(() {
                                      //     widget.emailMessage.important = false;
                                      //   });
                                      //
                                      //   // now inserting new data to previous cached data
                                      //   for( var msg in tempList ) {
                                      //     if( msg['msgId'] == widget.emailMessage.msgId ) {
                                      //       msg['important'] = false;
                                      //       break;
                                      //     }
                                      //   }
                                      //
                                      //   hiveService.addBoxes( tempList, " is:important CachedMessages" + widget.username );
                                      //
                                      //
                                      //   // modifying the messages label to remove UNREAD Label from the message
                                      //   gmail.ModifyMessageRequest req = gmail.ModifyMessageRequest(
                                      //       removeLabelIds: [
                                      //         "IMPORTANT"
                                      //       ]
                                      //   );
                                      //
                                      //   widget.gmailApi.users.messages.modify( req, 'me', widget.emailMessage.msgId);
                                      //
                                      //   setState(() { });
                                      // }
                                      // else {
                                      //   setState(() {
                                      //     widget.emailMessage.important = true;
                                      //   });
                                      //
                                      //   // now inserting new data to previous cached data
                                      //   for( var msg in tempList ) {
                                      //     if( msg['msgId'] == widget.emailMessage.msgId ) {
                                      //       msg['important'] = true;
                                      //       break;
                                      //     }
                                      //   }
                                      //
                                      //   hiveService.addBoxes( tempList, " is:important CachedMessages" + widget.username );
                                      //
                                      //
                                      //   // modifying the messages label to remove UNREAD Label from the message
                                      //   gmail.ModifyMessageRequest req = gmail.ModifyMessageRequest(
                                      //       addLabelIds: [
                                      //         "IMPORTANT"
                                      //       ]
                                      //   );
                                      //
                                      //   widget.gmailApi.users.messages.modify( req, 'me', widget.emailMessage.msgId);
                                      //
                                      //   setState(() {
                                      //
                                      //   });
                                      // }
                                    },
                                    child: Container(
                                      color: Colors.white,
                                      alignment: Alignment.center,
                                      // padding: EdgeInsets.symmetric(vertical: 8),
                                      child: Icon(
                                        Icons.label_important,
                                        // widget.emailMessage.important ? Icons.label_important : Icons.label_important_outline,
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
                                      // List<dynamic> tempList = await hiveService.getBoxes( " is:important CachedMessages" + widget.username );
                                      //
                                      // if (  widget.emailMessage.important ) {
                                      //   setState(() {
                                      //     widget.emailMessage.important = false;
                                      //   });
                                      //
                                      //   // now inserting new data to previous cached data
                                      //   for( var msg in tempList ) {
                                      //     if( msg['msgId'] == widget.emailMessage.msgId ) {
                                      //       msg['important'] = false;
                                      //       break;
                                      //     }
                                      //   }
                                      //
                                      //   hiveService.addBoxes( tempList, " is:important CachedMessages" + widget.username );
                                      //
                                      //
                                      //   // modifying the messages label to remove UNREAD Label from the message
                                      //   gmail.ModifyMessageRequest req = gmail.ModifyMessageRequest(
                                      //       removeLabelIds: [
                                      //         "IMPORTANT"
                                      //       ]
                                      //   );
                                      //
                                      //   widget.gmailApi.users.messages.modify( req, 'me', widget.emailMessage.msgId);
                                      //
                                      //   setState(() { });
                                      // }
                                      // else {
                                      //   setState(() {
                                      //     widget.emailMessage.important = true;
                                      //   });
                                      //
                                      //   // now inserting new data to previous cached data
                                      //   for( var msg in tempList ) {
                                      //     if( msg['msgId'] == widget.emailMessage.msgId ) {
                                      //       msg['important'] = true;
                                      //       break;
                                      //     }
                                      //   }
                                      //
                                      //   hiveService.addBoxes( tempList, " is:important CachedMessages" + widget.username );
                                      //
                                      //
                                      //   // modifying the messages label to remove UNREAD Label from the message
                                      //   gmail.ModifyMessageRequest req = gmail.ModifyMessageRequest(
                                      //       addLabelIds: [
                                      //         "IMPORTANT"
                                      //       ]
                                      //   );
                                      //
                                      //   widget.gmailApi.users.messages.modify( req, 'me', widget.emailMessage.msgId);
                                      //
                                      //   setState(() {
                                      //
                                      //   });
                                      // }
                                    },
                                    child: Container(
                                      color: Colors.white,
                                      alignment: Alignment.center,
                                      // padding: EdgeInsets.symmetric(vertical: 8),
                                      child: Icon(
                                        Icons.label_important,
                                        // widget.emailMessage.important ? Icons.label_important : Icons.label_important_outline,
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
                                      // List<dynamic> tempList = await hiveService.getBoxes( " is:important CachedMessages" + widget.username );
                                      //
                                      // if (  widget.emailMessage.important ) {
                                      //   setState(() {
                                      //     widget.emailMessage.important = false;
                                      //   });
                                      //
                                      //   // now inserting new data to previous cached data
                                      //   for( var msg in tempList ) {
                                      //     if( msg['msgId'] == widget.emailMessage.msgId ) {
                                      //       msg['important'] = false;
                                      //       break;
                                      //     }
                                      //   }
                                      //
                                      //   hiveService.addBoxes( tempList, " is:important CachedMessages" + widget.username );
                                      //
                                      //
                                      //   // modifying the messages label to remove UNREAD Label from the message
                                      //   gmail.ModifyMessageRequest req = gmail.ModifyMessageRequest(
                                      //       removeLabelIds: [
                                      //         "IMPORTANT"
                                      //       ]
                                      //   );
                                      //
                                      //   widget.gmailApi.users.messages.modify( req, 'me', widget.emailMessage.msgId);
                                      //
                                      //   setState(() { });
                                      // }
                                      // else {
                                      //   setState(() {
                                      //     widget.emailMessage.important = true;
                                      //   });
                                      //
                                      //   // now inserting new data to previous cached data
                                      //   for( var msg in tempList ) {
                                      //     if( msg['msgId'] == widget.emailMessage.msgId ) {
                                      //       msg['important'] = true;
                                      //       break;
                                      //     }
                                      //   }
                                      //
                                      //   hiveService.addBoxes( tempList, " is:important CachedMessages" + widget.username );
                                      //
                                      //
                                      //   // modifying the messages label to remove UNREAD Label from the message
                                      //   gmail.ModifyMessageRequest req = gmail.ModifyMessageRequest(
                                      //       addLabelIds: [
                                      //         "IMPORTANT"
                                      //       ]
                                      //   );
                                      //
                                      //   widget.gmailApi.users.messages.modify( req, 'me', widget.emailMessage.msgId);
                                      //
                                      //   setState(() {
                                      //
                                      //   });
                                      // }
                                    },
                                    child: Container(
                                      color: Colors.white,
                                      alignment: Alignment.center,
                                      // padding: EdgeInsets.symmetric(vertical: 8),
                                      child: Icon(
                                        Icons.label_important,
                                        // widget.emailMessage.important ? Icons.label_important : Icons.label_important_outline,
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
                                      // List<dynamic> tempList = await hiveService.getBoxes( " is:important CachedMessages" + widget.username );
                                      //
                                      // if (  widget.emailMessage.important ) {
                                      //   setState(() {
                                      //     widget.emailMessage.important = false;
                                      //   });
                                      //
                                      //   // now inserting new data to previous cached data
                                      //   for( var msg in tempList ) {
                                      //     if( msg['msgId'] == widget.emailMessage.msgId ) {
                                      //       msg['important'] = false;
                                      //       break;
                                      //     }
                                      //   }
                                      //
                                      //   hiveService.addBoxes( tempList, " is:important CachedMessages" + widget.username );
                                      //
                                      //
                                      //   // modifying the messages label to remove UNREAD Label from the message
                                      //   gmail.ModifyMessageRequest req = gmail.ModifyMessageRequest(
                                      //       removeLabelIds: [
                                      //         "IMPORTANT"
                                      //       ]
                                      //   );
                                      //
                                      //   widget.gmailApi.users.messages.modify( req, 'me', widget.emailMessage.msgId);
                                      //
                                      //   setState(() { });
                                      // }
                                      // else {
                                      //   setState(() {
                                      //     widget.emailMessage.important = true;
                                      //   });
                                      //
                                      //   // now inserting new data to previous cached data
                                      //   for( var msg in tempList ) {
                                      //     if( msg['msgId'] == widget.emailMessage.msgId ) {
                                      //       msg['important'] = true;
                                      //       break;
                                      //     }
                                      //   }
                                      //
                                      //   hiveService.addBoxes( tempList, " is:important CachedMessages" + widget.username );
                                      //
                                      //
                                      //   // modifying the messages label to remove UNREAD Label from the message
                                      //   gmail.ModifyMessageRequest req = gmail.ModifyMessageRequest(
                                      //       addLabelIds: [
                                      //         "IMPORTANT"
                                      //       ]
                                      //   );
                                      //
                                      //   widget.gmailApi.users.messages.modify( req, 'me', widget.emailMessage.msgId);
                                      //
                                      //   setState(() {
                                      //
                                      //   });
                                      // }
                                    },
                                    child: Container(
                                      color: Colors.white,
                                      alignment: Alignment.center,
                                      // padding: EdgeInsets.symmetric(vertical: 8),
                                      child: Icon(
                                        Icons.label_important,
                                        // widget.emailMessage.important ? Icons.label_important : Icons.label_important_outline,
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
                                      // List<dynamic> tempList = await hiveService.getBoxes( " is:important CachedMessages" + widget.username );
                                      //
                                      // if (  widget.emailMessage.important ) {
                                      //   setState(() {
                                      //     widget.emailMessage.important = false;
                                      //   });
                                      //
                                      //   // now inserting new data to previous cached data
                                      //   for( var msg in tempList ) {
                                      //     if( msg['msgId'] == widget.emailMessage.msgId ) {
                                      //       msg['important'] = false;
                                      //       break;
                                      //     }
                                      //   }
                                      //
                                      //   hiveService.addBoxes( tempList, " is:important CachedMessages" + widget.username );
                                      //
                                      //
                                      //   // modifying the messages label to remove UNREAD Label from the message
                                      //   gmail.ModifyMessageRequest req = gmail.ModifyMessageRequest(
                                      //       removeLabelIds: [
                                      //         "IMPORTANT"
                                      //       ]
                                      //   );
                                      //
                                      //   widget.gmailApi.users.messages.modify( req, 'me', widget.emailMessage.msgId);
                                      //
                                      //   setState(() { });
                                      // }
                                      // else {
                                      //   setState(() {
                                      //     widget.emailMessage.important = true;
                                      //   });
                                      //
                                      //   // now inserting new data to previous cached data
                                      //   for( var msg in tempList ) {
                                      //     if( msg['msgId'] == widget.emailMessage.msgId ) {
                                      //       msg['important'] = true;
                                      //       break;
                                      //     }
                                      //   }
                                      //
                                      //   hiveService.addBoxes( tempList, " is:important CachedMessages" + widget.username );
                                      //
                                      //
                                      //   // modifying the messages label to remove UNREAD Label from the message
                                      //   gmail.ModifyMessageRequest req = gmail.ModifyMessageRequest(
                                      //       addLabelIds: [
                                      //         "IMPORTANT"
                                      //       ]
                                      //   );
                                      //
                                      //   widget.gmailApi.users.messages.modify( req, 'me', widget.emailMessage.msgId);
                                      //
                                      //   setState(() {
                                      //
                                      //   });
                                      // }
                                    },
                                    child: Container(
                                      color: Colors.white,
                                      alignment: Alignment.center,
                                      // padding: EdgeInsets.symmetric(vertical: 8),
                                      child: Icon(
                                        Icons.label_important,
                                        // widget.emailMessage.important ? Icons.label_important : Icons.label_important_outline,
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
                                      // List<dynamic> tempList = await hiveService.getBoxes( " is:important CachedMessages" + widget.username );
                                      //
                                      // if (  widget.emailMessage.important ) {
                                      //   setState(() {
                                      //     widget.emailMessage.important = false;
                                      //   });
                                      //
                                      //   // now inserting new data to previous cached data
                                      //   for( var msg in tempList ) {
                                      //     if( msg['msgId'] == widget.emailMessage.msgId ) {
                                      //       msg['important'] = false;
                                      //       break;
                                      //     }
                                      //   }
                                      //
                                      //   hiveService.addBoxes( tempList, " is:important CachedMessages" + widget.username );
                                      //
                                      //
                                      //   // modifying the messages label to remove UNREAD Label from the message
                                      //   gmail.ModifyMessageRequest req = gmail.ModifyMessageRequest(
                                      //       removeLabelIds: [
                                      //         "IMPORTANT"
                                      //       ]
                                      //   );
                                      //
                                      //   widget.gmailApi.users.messages.modify( req, 'me', widget.emailMessage.msgId);
                                      //
                                      //   setState(() { });
                                      // }
                                      // else {
                                      //   setState(() {
                                      //     widget.emailMessage.important = true;
                                      //   });
                                      //
                                      //   // now inserting new data to previous cached data
                                      //   for( var msg in tempList ) {
                                      //     if( msg['msgId'] == widget.emailMessage.msgId ) {
                                      //       msg['important'] = true;
                                      //       break;
                                      //     }
                                      //   }
                                      //
                                      //   hiveService.addBoxes( tempList, " is:important CachedMessages" + widget.username );
                                      //
                                      //
                                      //   // modifying the messages label to remove UNREAD Label from the message
                                      //   gmail.ModifyMessageRequest req = gmail.ModifyMessageRequest(
                                      //       addLabelIds: [
                                      //         "IMPORTANT"
                                      //       ]
                                      //   );
                                      //
                                      //   widget.gmailApi.users.messages.modify( req, 'me', widget.emailMessage.msgId);
                                      //
                                      //   setState(() {
                                      //
                                      //   });
                                      // }
                                    },
                                    child: Container(
                                      color: Colors.white,
                                      alignment: Alignment.center,
                                      // padding: EdgeInsets.symmetric(vertical: 8),
                                      child: Icon(
                                        Icons.label_important,
                                        // widget.emailMessage.important ? Icons.label_important : Icons.label_important_outline,
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
                                      // List<dynamic> tempList = await hiveService.getBoxes( " is:important CachedMessages" + widget.username );
                                      //
                                      // if (  widget.emailMessage.important ) {
                                      //   setState(() {
                                      //     widget.emailMessage.important = false;
                                      //   });
                                      //
                                      //   // now inserting new data to previous cached data
                                      //   for( var msg in tempList ) {
                                      //     if( msg['msgId'] == widget.emailMessage.msgId ) {
                                      //       msg['important'] = false;
                                      //       break;
                                      //     }
                                      //   }
                                      //
                                      //   hiveService.addBoxes( tempList, " is:important CachedMessages" + widget.username );
                                      //
                                      //
                                      //   // modifying the messages label to remove UNREAD Label from the message
                                      //   gmail.ModifyMessageRequest req = gmail.ModifyMessageRequest(
                                      //       removeLabelIds: [
                                      //         "IMPORTANT"
                                      //       ]
                                      //   );
                                      //
                                      //   widget.gmailApi.users.messages.modify( req, 'me', widget.emailMessage.msgId);
                                      //
                                      //   setState(() { });
                                      // }
                                      // else {
                                      //   setState(() {
                                      //     widget.emailMessage.important = true;
                                      //   });
                                      //
                                      //   // now inserting new data to previous cached data
                                      //   for( var msg in tempList ) {
                                      //     if( msg['msgId'] == widget.emailMessage.msgId ) {
                                      //       msg['important'] = true;
                                      //       break;
                                      //     }
                                      //   }
                                      //
                                      //   hiveService.addBoxes( tempList, " is:important CachedMessages" + widget.username );
                                      //
                                      //
                                      //   // modifying the messages label to remove UNREAD Label from the message
                                      //   gmail.ModifyMessageRequest req = gmail.ModifyMessageRequest(
                                      //       addLabelIds: [
                                      //         "IMPORTANT"
                                      //       ]
                                      //   );
                                      //
                                      //   widget.gmailApi.users.messages.modify( req, 'me', widget.emailMessage.msgId);
                                      //
                                      //   setState(() {
                                      //
                                      //   });
                                      // }
                                    },
                                    child: Container(
                                      color: Colors.white,
                                      alignment: Alignment.center,
                                      // padding: EdgeInsets.symmetric(vertical: 8),
                                      child: Icon(
                                        Icons.label_important,
                                        // widget.emailMessage.important ? Icons.label_important : Icons.label_important_outline,
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
                                      // List<dynamic> tempList = await hiveService.getBoxes( " is:important CachedMessages" + widget.username );
                                      //
                                      // if (  widget.emailMessage.important ) {
                                      //   setState(() {
                                      //     widget.emailMessage.important = false;
                                      //   });
                                      //
                                      //   // now inserting new data to previous cached data
                                      //   for( var msg in tempList ) {
                                      //     if( msg['msgId'] == widget.emailMessage.msgId ) {
                                      //       msg['important'] = false;
                                      //       break;
                                      //     }
                                      //   }
                                      //
                                      //   hiveService.addBoxes( tempList, " is:important CachedMessages" + widget.username );
                                      //
                                      //
                                      //   // modifying the messages label to remove UNREAD Label from the message
                                      //   gmail.ModifyMessageRequest req = gmail.ModifyMessageRequest(
                                      //       removeLabelIds: [
                                      //         "IMPORTANT"
                                      //       ]
                                      //   );
                                      //
                                      //   widget.gmailApi.users.messages.modify( req, 'me', widget.emailMessage.msgId);
                                      //
                                      //   setState(() { });
                                      // }
                                      // else {
                                      //   setState(() {
                                      //     widget.emailMessage.important = true;
                                      //   });
                                      //
                                      //   // now inserting new data to previous cached data
                                      //   for( var msg in tempList ) {
                                      //     if( msg['msgId'] == widget.emailMessage.msgId ) {
                                      //       msg['important'] = true;
                                      //       break;
                                      //     }
                                      //   }
                                      //
                                      //   hiveService.addBoxes( tempList, " is:important CachedMessages" + widget.username );
                                      //
                                      //
                                      //   // modifying the messages label to remove UNREAD Label from the message
                                      //   gmail.ModifyMessageRequest req = gmail.ModifyMessageRequest(
                                      //       addLabelIds: [
                                      //         "IMPORTANT"
                                      //       ]
                                      //   );
                                      //
                                      //   widget.gmailApi.users.messages.modify( req, 'me', widget.emailMessage.msgId);
                                      //
                                      //   setState(() {
                                      //
                                      //   });
                                      // }
                                    },
                                    child: Container(
                                      color: Colors.white,
                                      alignment: Alignment.center,
                                      // padding: EdgeInsets.symmetric(vertical: 8),
                                      child: Icon(
                                        Icons.label_important,
                                        // widget.emailMessage.important ? Icons.label_important : Icons.label_important_outline,
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
                                      // List<dynamic> tempList = await hiveService.getBoxes( " is:important CachedMessages" + widget.username );
                                      //
                                      // if (  widget.emailMessage.important ) {
                                      //   setState(() {
                                      //     widget.emailMessage.important = false;
                                      //   });
                                      //
                                      //   // now inserting new data to previous cached data
                                      //   for( var msg in tempList ) {
                                      //     if( msg['msgId'] == widget.emailMessage.msgId ) {
                                      //       msg['important'] = false;
                                      //       break;
                                      //     }
                                      //   }
                                      //
                                      //   hiveService.addBoxes( tempList, " is:important CachedMessages" + widget.username );
                                      //
                                      //
                                      //   // modifying the messages label to remove UNREAD Label from the message
                                      //   gmail.ModifyMessageRequest req = gmail.ModifyMessageRequest(
                                      //       removeLabelIds: [
                                      //         "IMPORTANT"
                                      //       ]
                                      //   );
                                      //
                                      //   widget.gmailApi.users.messages.modify( req, 'me', widget.emailMessage.msgId);
                                      //
                                      //   setState(() { });
                                      // }
                                      // else {
                                      //   setState(() {
                                      //     widget.emailMessage.important = true;
                                      //   });
                                      //
                                      //   // now inserting new data to previous cached data
                                      //   for( var msg in tempList ) {
                                      //     if( msg['msgId'] == widget.emailMessage.msgId ) {
                                      //       msg['important'] = true;
                                      //       break;
                                      //     }
                                      //   }
                                      //
                                      //   hiveService.addBoxes( tempList, " is:important CachedMessages" + widget.username );
                                      //
                                      //
                                      //   // modifying the messages label to remove UNREAD Label from the message
                                      //   gmail.ModifyMessageRequest req = gmail.ModifyMessageRequest(
                                      //       addLabelIds: [
                                      //         "IMPORTANT"
                                      //       ]
                                      //   );
                                      //
                                      //   widget.gmailApi.users.messages.modify( req, 'me', widget.emailMessage.msgId);
                                      //
                                      //   setState(() {
                                      //
                                      //   });
                                      // }
                                    },
                                    child: Container(
                                      color: Colors.white,
                                      alignment: Alignment.center,
                                      // padding: EdgeInsets.symmetric(vertical: 8),
                                      child: Icon(
                                        Icons.label_important,
                                        // widget.emailMessage.important ? Icons.label_important : Icons.label_important_outline,
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
                                      // List<dynamic> tempList = await hiveService.getBoxes( " is:important CachedMessages" + widget.username );
                                      //
                                      // if (  widget.emailMessage.important ) {
                                      //   setState(() {
                                      //     widget.emailMessage.important = false;
                                      //   });
                                      //
                                      //   // now inserting new data to previous cached data
                                      //   for( var msg in tempList ) {
                                      //     if( msg['msgId'] == widget.emailMessage.msgId ) {
                                      //       msg['important'] = false;
                                      //       break;
                                      //     }
                                      //   }
                                      //
                                      //   hiveService.addBoxes( tempList, " is:important CachedMessages" + widget.username );
                                      //
                                      //
                                      //   // modifying the messages label to remove UNREAD Label from the message
                                      //   gmail.ModifyMessageRequest req = gmail.ModifyMessageRequest(
                                      //       removeLabelIds: [
                                      //         "IMPORTANT"
                                      //       ]
                                      //   );
                                      //
                                      //   widget.gmailApi.users.messages.modify( req, 'me', widget.emailMessage.msgId);
                                      //
                                      //   setState(() { });
                                      // }
                                      // else {
                                      //   setState(() {
                                      //     widget.emailMessage.important = true;
                                      //   });
                                      //
                                      //   // now inserting new data to previous cached data
                                      //   for( var msg in tempList ) {
                                      //     if( msg['msgId'] == widget.emailMessage.msgId ) {
                                      //       msg['important'] = true;
                                      //       break;
                                      //     }
                                      //   }
                                      //
                                      //   hiveService.addBoxes( tempList, " is:important CachedMessages" + widget.username );
                                      //
                                      //
                                      //   // modifying the messages label to remove UNREAD Label from the message
                                      //   gmail.ModifyMessageRequest req = gmail.ModifyMessageRequest(
                                      //       addLabelIds: [
                                      //         "IMPORTANT"
                                      //       ]
                                      //   );
                                      //
                                      //   widget.gmailApi.users.messages.modify( req, 'me', widget.emailMessage.msgId);
                                      //
                                      //   setState(() {
                                      //
                                      //   });
                                      // }
                                    },
                                    child: Container(
                                      color: Colors.white,
                                      alignment: Alignment.center,
                                      // padding: EdgeInsets.symmetric(vertical: 8),
                                      child: Icon(
                                        Icons.label_important,
                                        // widget.emailMessage.important ? Icons.label_important : Icons.label_important_outline,
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
                                      // List<dynamic> tempList = await hiveService.getBoxes( " is:important CachedMessages" + widget.username );
                                      //
                                      // if (  widget.emailMessage.important ) {
                                      //   setState(() {
                                      //     widget.emailMessage.important = false;
                                      //   });
                                      //
                                      //   // now inserting new data to previous cached data
                                      //   for( var msg in tempList ) {
                                      //     if( msg['msgId'] == widget.emailMessage.msgId ) {
                                      //       msg['important'] = false;
                                      //       break;
                                      //     }
                                      //   }
                                      //
                                      //   hiveService.addBoxes( tempList, " is:important CachedMessages" + widget.username );
                                      //
                                      //
                                      //   // modifying the messages label to remove UNREAD Label from the message
                                      //   gmail.ModifyMessageRequest req = gmail.ModifyMessageRequest(
                                      //       removeLabelIds: [
                                      //         "IMPORTANT"
                                      //       ]
                                      //   );
                                      //
                                      //   widget.gmailApi.users.messages.modify( req, 'me', widget.emailMessage.msgId);
                                      //
                                      //   setState(() { });
                                      // }
                                      // else {
                                      //   setState(() {
                                      //     widget.emailMessage.important = true;
                                      //   });
                                      //
                                      //   // now inserting new data to previous cached data
                                      //   for( var msg in tempList ) {
                                      //     if( msg['msgId'] == widget.emailMessage.msgId ) {
                                      //       msg['important'] = true;
                                      //       break;
                                      //     }
                                      //   }
                                      //
                                      //   hiveService.addBoxes( tempList, " is:important CachedMessages" + widget.username );
                                      //
                                      //
                                      //   // modifying the messages label to remove UNREAD Label from the message
                                      //   gmail.ModifyMessageRequest req = gmail.ModifyMessageRequest(
                                      //       addLabelIds: [
                                      //         "IMPORTANT"
                                      //       ]
                                      //   );
                                      //
                                      //   widget.gmailApi.users.messages.modify( req, 'me', widget.emailMessage.msgId);
                                      //
                                      //   setState(() {
                                      //
                                      //   });
                                      // }
                                    },
                                    child: Container(
                                      color: Colors.white,
                                      alignment: Alignment.center,
                                      // padding: EdgeInsets.symmetric(vertical: 8),
                                      child: Icon(
                                        Icons.label_important,
                                        // widget.emailMessage.important ? Icons.label_important : Icons.label_important_outline,
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
                  ),
                ],
              ),
            )
        )
    );
  }
}