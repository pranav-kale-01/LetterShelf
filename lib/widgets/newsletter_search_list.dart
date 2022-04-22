import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:googleapis/gmail/v1.dart' as gmail;
import 'package:letter_shelf/models/emailMessage.dart';
import 'package:letter_shelf/utils/OAuthClient.dart';
import 'package:letter_shelf/utils/Utils.dart';

import 'package:hive/hive.dart';
import 'package:letter_shelf/utils/hive_services.dart';

import '../utils/CreateLoggedinUser.dart';
import 'HomeScreenListTile.dart';

class NewsletterSearchList extends StatefulWidget {
  final gmail.GmailApi gmailApi;
  final String queryStringAddOn;
  final Function addToListMethod;
  final Function removeFromListMethod;

  late Function addElementToTop;
  late Function removeElement;

  bool loaded = false;
  bool queryStringBuilt = false;
  bool breakLoop = false;

  NewsletterSearchList({
    Key? key,
    required this.gmailApi,
    required this.queryStringAddOn,
    required this.addToListMethod,
    required this.removeFromListMethod,
  }) : super(key: key);

  @override
  _NewsletterSearchListState createState() => _NewsletterSearchListState();
}

class _NewsletterSearchListState extends State<NewsletterSearchList> {
  late Future<void> myFuture;
  late Map<String, dynamic> visibleMessages = {};
  late Set<String> tempMsgIds;
  late ScrollController controller;
  late String queryString = '';

  final HiveServices hiveService = HiveServices( );

  int currentIndex = 0;
  int maxResults = 500;
  bool executeOnTap = true;
  late String username;
  bool hasInternetConnection = true;

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
    // checking if user has internet connection
    hasInternetConnection = await Utils.hasNetwork();

    if( hasInternetConnection ) {
      // getting username
      username = await OAuthClient.getCurrentUserNameFromApi(widget.gmailApi);

      await _getEmailMessages( false );
    }
    else {
      setState(() { });
    }
  }

  void handleBottomListScrolling() {
    // if the list has been scrolled down to the end
    if (controller.position.maxScrollExtent == controller.offset) {
      debugPrint('load more');

      _loadEmailMessages(currentIndex + 15);
    }
  }

  Future<void> _loadEmailMessages(int limit) async {
    try {
      if (widget.loaded) {
        return;
      }

      setState(() => widget.loaded = true );

      int batchCount=0;

      while (currentIndex < limit && currentIndex < maxResults - 1 ) {

        if( widget.breakLoop )
        {
          widget.breakLoop = false;
          return;
        }

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

        bool isUnread = false;
        for( var i in msg.labelIds! ) {
          if( i == "UNREAD" ) {
            isUnread = true;
          }
        }

        if( !widget.breakLoop ) {
          if( batchCount > 5 ) {
            batchCount=0;

            setState(() { });
          }

          // creating an object of EmailMessage
          EmailMessage msg = EmailMessage(
              msgId: tempMsgIds.elementAt(currentIndex),
              from: from,
              date: date,
              subject: subject,
              image: '',
              unread: isUnread
          );

          visibleMessages.addAll({tempMsgIds.elementAt(currentIndex): msg});

          currentIndex += 1;
        }
      }

      setState(() => widget.loaded = false );
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

    // loading the newsletters file from memory
    final localPath = await Utils.localPath;
    final String username = await OAuthClient.getCurrentUserNameFromApi(widget.gmailApi);

    final File newslettersFile = File(localPath.path + '/newsletterslist_' + username + '.json');

    // reading the file
    List<dynamic> jsonList = jsonDecode(await newslettersFile.readAsString());

    int count=0;
    for (var json in jsonList) {
      if (json['email'] != null && json['enabled'] == true ) {
        queryString += '( from: "' + json['name'] + '" AND { "${widget.queryStringAddOn}" (';

        // trimming the string
        String searchString = widget.queryStringAddOn.trim();
        for( var i in searchString.split(" ") ) {
          queryString += " $i";
        }
        queryString += ") }";

        // checking if the searched string is the same as the newsletter's name
        if( json['name'].toString().toUpperCase().contains( searchString.toUpperCase() ) ) {
          queryString += ') OR ( from:"${json['name']}" ';
        }

        if( count < jsonList.length - 2 ) {
          queryString += ") OR ";
        }
        else{
          queryString += ") ";
        }
        count+=1;
      }
    }

    // checking queryString is empty
    if( queryString.length == 2 ) {
      queryString = "{from: _}";
    }

    debugPrint( queryString );

    return queryString;
  }

  Future<void> _getEmailMessages( bool _breakLoop ) async {
    try {
      // checking if user has internet connection
      hasInternetConnection = await Utils.hasNetwork();

      if ( hasInternetConnection ) {
        String result = '' ;

        if ( queryString.isEmpty ) {
          queryString = await _createQueryString();
        }

        result = queryString;

        gmail.ListMessagesResponse clientMessages = await widget.gmailApi.users.messages.list('me', maxResults: maxResults, q: result );

        if( clientMessages.messages == null ) {
          setState( () => widget.loaded = true );
          return;
        }

        tempMsgIds = clientMessages.messages!.map((message) {
          return message.id.toString();
        }).toSet();

        if( _breakLoop ) {
          widget.breakLoop = false;
        }

        _loadEmailMessages( tempMsgIds.length < 6 ? tempMsgIds.length : 6 );
      }
    } catch (e, stacktrace) {
      debugPrint(e.toString());
      debugPrint(stacktrace.toString());
    }
  }

  void addElementToTop(EmailMessage msg) {
    setState(() {
      top.add(msg);
    });
  }

  void removeElement(String msgId) {
    setState(() {
      visibleMessages.removeWhere((key, value) => key == msgId);
    });
  }

  @override
  Widget build(BuildContext context) {
    const Key centerKey = ValueKey('second-sliver-list');

    // setting the super class's addToList and removeFromList methods
    widget.addElementToTop = addElementToTop;
    widget.removeElement = removeElement;

    int messagesLength = visibleMessages.length;

    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          widget.loaded = false;
        });

        widget.breakLoop = true;

        setState(() {
          visibleMessages = {};
        });

        currentIndex=0;
        await _getEmailMessages( true );
      },
      child: CustomScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        controller: controller,
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
          visibleMessages.values.isNotEmpty ? SliverList(
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
          ) : hasInternetConnection ? widget.loaded ? SliverToBoxAdapter(
            key: centerKey,
            child: Container(
              margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.25),
              alignment: Alignment.center,
              child: const Text("No matching results found"),
            ),
          ) : SliverToBoxAdapter(
            key: centerKey,
            child: Container(
              margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.25),
              alignment: Alignment.center,
              child: const CircularProgressIndicator(),
            ),
          ) : SliverToBoxAdapter(
            key: centerKey,
            child: Container(
              margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.25),
              alignment: Alignment.center,
              child: const Text("No Internet Connection"),
            ),
          ),
        ],
      ),
    );
  }
}
