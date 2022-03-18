import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:googleapis/gmail/v1.dart' as gmail;
import 'package:letter_shelf/models/emailMessage.dart';
import 'package:letter_shelf/utils/OAuthClient.dart';
import 'package:letter_shelf/utils/Utils.dart';

import '../utils/CreateLoggedinUser.dart';
import 'HomeScreenListTile.dart';

class HomeScreenList extends StatefulWidget {
  final gmail.GmailApi gmailApi;
  final String queryStringAddOn;
  final Function addToListMethod;
  final Function removeFromListMethod;

  late Function addElementToTop;
  late Function removeElement;

  bool loaded = false;
  bool queryStringBuilt = false;
  bool breakLoop = false;

  HomeScreenList({
    Key? key,
    required this.gmailApi,
    required this.queryStringAddOn,
    required this.addToListMethod,
    required this.removeFromListMethod,
  }) : super(key: key);

  @override
  _HomeScreenListState createState() => _HomeScreenListState();
}

class _HomeScreenListState extends State<HomeScreenList> with AutomaticKeepAliveClientMixin<HomeScreenList> {
  late Future<void> myFuture;
  late Map<String, dynamic> visibleMessages = {};
  late Set<String> tempMsgIds;
  late ScrollController controller;
  late String queryString = '';

  int currentIndex = 0;
  int maxResults = 500;
  bool executeOnTap = true;

  late List<EmailMessage> top = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    controller = ScrollController()..addListener(handleBottomListScrolling);
    myFuture = init();
  }

  Future<void> init() async {
    // first creating a logged in user account, to indicate that the sign up process was successful
    CreateLoggedinUser(api: widget.gmailApi);
    await _getEmailMessages( false );
  }

  void handleBottomListScrolling() {
    // if the list has been scrolled down to the en
    if (controller.position.maxScrollExtent == controller.offset) {
      _loadEmailMessages(currentIndex + 10);
    }
  }

  Future<void> _loadEmailMessages(int limit) async {
    try {
      // debugPrint( '_loadEmailMessages'  + widget.breakLoop.toString() );

      if (widget.loaded) {
        return;
      }
      widget.loaded = true;

      // debugPrint('-----');

      while (currentIndex < limit && currentIndex < maxResults - 1 ) {

        if( widget.breakLoop )
        {
          widget.breakLoop = false;
          return;
        }

        // debugPrint('here ' + currentIndex.toString() );

        final String msgId = tempMsgIds.elementAt(currentIndex);
        gmail.Message msg = await widget.gmailApi.users.messages.get('me', msgId, format: "metadata");
        List<gmail.MessagePartHeader>? headers = msg.payload?.headers;

        late String subject, date, from;

        for (gmail.MessagePartHeader header in headers!) {
          if (header.name == 'Subject') {
            subject = header.value!;
          } else if (header.name == 'From') {
            from = header.value!;
          } else if (header.name == 'Date') {
            date = header.value!;
          }
        } // headers loop ends here

        if( !widget.breakLoop ) {
          setState(() {
            // creating an object of EmailMessage
            EmailMessage msg = EmailMessage(
                msgId: tempMsgIds.elementAt(currentIndex),
                from: from,
                date: date,
                subject: subject,
                image: '');

            visibleMessages.addAll({tempMsgIds.elementAt(currentIndex): msg});
          });

          currentIndex += 1;
        }
      }

      widget.loaded = false;
    }
    catch( e, stacktrace ) {
      debugPrint( e.toString() );
      debugPrint( stacktrace.toString() );
    }
  }

  Future<String> _createQueryString() async {
    if (widget.queryStringBuilt) {
      return '';
    }
    widget.queryStringBuilt = true;

    // loading the newslettersfile from memory
    final localPath = await Utils.localPath;
    final String username = await OAuthClient.getCurrentUserNameFromApi(widget.gmailApi);

    final File newslettersFile = File(localPath.path + '/newsletterslist_' + username + '.json');

    // reading the file
    List<dynamic> jsonList = jsonDecode(await newslettersFile.readAsString());

    String queryString = '{';

    for (var json in jsonList) {
      if (json['email'] != null) {
        queryString += 'from:' + json['email'] + ' ';
      }
    }
    queryString += '}';

    return queryString;
  }

  Future<void> _getEmailMessages( bool _breakLoop ) async {
    try {
      String result = '' ;

      if ( queryString.isEmpty ) {
        queryString = await _createQueryString();
      }
      result = queryString;

      // debugPrint("HomeScreenList - " + widget.queryStringAddOn + queryString);

      gmail.ListMessagesResponse clientMessages = await widget.gmailApi.users.messages.list('me', maxResults: maxResults, q: widget.queryStringAddOn + result );

      tempMsgIds = clientMessages.messages!.map((message) {
        return message.id.toString();
      }).toSet();

      if( _breakLoop ) {
        widget.breakLoop = false;
      }

      _loadEmailMessages(25);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void addElementToTop(EmailMessage msg) {
    debugPrint('addElementToTop');
    setState(() {
      top.add(msg);
    });
  }

  void removeElement(String msgId) {
    debugPrint('removeElement');
    // EmailMessage msg = visibleMessages[msgId];

    setState(() {
      visibleMessages.removeWhere((key, value) => key == msgId);
    });
  }

  CustomScrollView? _tempView;

  @override
  Widget build(BuildContext context) {
    const Key centerKey = ValueKey('second-sliver-list');

    // setting the super class's addToList and removeFromList methods
    widget.addElementToTop = addElementToTop;
    widget.removeElement = removeElement;

    int messagesLength = visibleMessages.length;

    // debugPrint("HomeScreenList - loaded" + widget.loaded.toString() );

    return RefreshIndicator(
      onRefresh: () async {
        // checking if there are any new messages..
        widget.loaded = false;
        widget.breakLoop = true;

        setState(() {
          visibleMessages = {};
        });

        currentIndex=0;
        await _getEmailMessages( true );
      },
      child: CustomScrollView(
        center: centerKey,
        slivers: [
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                return HomeScreenListTile(
                  listKey: widget.key.toString(),
                  gmailApi: widget.gmailApi,
                  emailMessage: top[index],
                  addToListMethod: widget.addToListMethod,
                  removeFromListMethod: removeElement,
                );
              },
              childCount: top.length,
            ),
          ),
          SliverList(
            // Key parameter makes this list grow bottom
            key: centerKey,
            delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                return HomeScreenListTile(
                  listKey: widget.key.toString() ,
                  gmailApi: widget.gmailApi,
                  emailMessage: visibleMessages.values.toList()[index],
                  addToListMethod: widget.addToListMethod,
                  removeFromListMethod: removeElement,
                );
              },
              childCount: messagesLength,
            ),
          ),
        ],
      ),

      // child: CustomScrollView(
      //   center: centerKey,
      //   slivers: [
      //     SliverList(
      //       delegate: SliverChildBuilderDelegate(
      //         (BuildContext context, int index) {
      //           return HomeScreenListTile(
      //             listKey: widget.key.toString(),
      //             gmailApi: widget.gmailApi,
      //             emailMessage: top[index],
      //             addToListMethod: widget.addToListMethod,
      //             removeFromListMethod: removeElement,
      //           );
      //         },
      //         childCount: top.length,
      //       ),
      //     ),
      //     SliverList(
      //       // Key parameter makes this list grow bottom
      //       key: centerKey,
      //       delegate: SliverChildBuilderDelegate(
      //         (BuildContext context, int index) {
      //           return HomeScreenListTile(
      //             listKey: widget.key.toString() ,
      //             gmailApi: widget.gmailApi,
      //             emailMessage: visibleMessages.values.toList()[index],
      //             addToListMethod: widget.addToListMethod,
      //             removeFromListMethod: removeElement,
      //           );
      //         },
      //         childCount: messagesLength,
      //       ),
      //     ),
      //   ],
      // ),
    );
  }
}
