import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:googleapis/gmail/v1.dart' as gmail;
import 'package:intl/intl.dart';
import 'package:letter_shelf/models/emailMessage.dart';
import 'package:letter_shelf/utils/OAuthClient.dart';
import 'package:letter_shelf/utils/Utils.dart';

import 'package:letter_shelf/utils/hive_services.dart';
import 'package:letter_shelf/widgets/home_screen/HomeScreenListTile.dart';

class NewsletterSearchList extends StatefulWidget {
  final gmail.GmailApi gmailApi;
  final String queryStringAddOn;
  final Function addToListMethod;
  final Function removeFromListMethod;
  final Map<String,dynamic> queryFilters;

  late Function addElementToTop;
  late Function removeElement;

  bool loaded = false;
  bool queryStringBuilt = false;
  bool breakLoop = false;
  bool refreshList;

  // for date filters
  final List<String> dateFilters = [
    "any time",
    "older than a week",
    "older than a month",
    "older than 6 months",
    "older than a year",
  ];

  NewsletterSearchList({
    Key? key,
    required this.gmailApi,
    required this.queryStringAddOn,
    required this.addToListMethod,
    required this.removeFromListMethod,
    required this.queryFilters,
    this.refreshList = false,
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
  ScrollPhysics _physics = const ClampingScrollPhysics();

  bool hasInternetConnection = true;
  bool loadingMore = false;

  late List<EmailMessage> top = [];

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
      if (!loadingMore) {
        setState(() {
          loadingMore = true;
          controller.animateTo(controller.position.maxScrollExtent,
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutExpo);
        });

        _loadEmailMessages(
            currentIndex + 10 > tempMsgIds.length ? tempMsgIds.length -
                currentIndex : currentIndex + 10);
      }
    }

    if (controller.position.pixels <= 56) {
      if( controller.position.pixels < 0 ) {
        controller.jumpTo(0);
      }
      setState(() => _physics = const ClampingScrollPhysics());
    }
    else {
      setState(() => _physics = const BouncingScrollPhysics());
    }
  }

  Future<void> _loadEmailMessages(int limit) async {
    try {
      if (widget.loaded) {
        return;
      }

      setState(() => widget.loaded = true );

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
          setState(() { });

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

    // debugPrint("queryString - " + widget.queryFilters.toString() );

    if( widget.queryFilters["search in all mails"] != null && widget.queryFilters["search in all mails"] == true) {
      queryString = widget.queryStringAddOn.trim();
    }
    else {
      // loading the newsletters file from memory
      final localPath = await Utils.localPath;
      final String username = await OAuthClient.getCurrentUserNameFromApi(widget.gmailApi);

      final File newslettersFile = File(localPath.path + '/newsletterslist_' + username + '.json');

      // reading the file
      List<dynamic> jsonList = jsonDecode(await newslettersFile.readAsString());

      int count=1;
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

          debugPrint( count.toString() );
          if( count < jsonList.length - 1 ) {
            queryString += ") OR ";
          }
          else{
            queryString += ") ";
          }
          count+=1;
        }
      }
    }

    // adding the is unread filter if selected
    if( widget.queryFilters["Is unread"] != null && widget.queryFilters["Is unread"] == true ) {
      queryString += " is:unread";
    }

    // adding the labels for searching if the user selected any
    if( widget.queryFilters["labels"] != null ) {
      Map<String,dynamic> labels =  widget.queryFilters["labels"];

      for( String i in labels.keys.toList() ) {
        // if the label is enabled in the search filters then adding the label query in the query string
        if( labels[i] == true ) {
          queryString += " label:$i";
        }
      }
    }

    // adding the date filters if the user selected any
    if( widget.queryFilters["date"] != null ) {
      // getting the current date
      DateTime today = DateTime.now();
      DateFormat dateFormat = DateFormat("y/MM/d");


      if( widget.queryFilters["date"] == widget.dateFilters[1] ) {
        // older than a week
        queryString += " older:${dateFormat.format( today.subtract( const Duration(days: 7) ) )}";
      }
      else if( widget.queryFilters["date"] == widget.dateFilters[2] ) {
        // older than a month
        DateTime newDate = DateTime( today.year, today.month -1, today.day, );
        queryString += " older:${dateFormat.format(newDate)}";
      }
      else if( widget.queryFilters["date"] == widget.dateFilters[3] ) {
        // older than 6 months
        DateTime newDate = DateTime( today.year, today.month - 6, today.day, );
        queryString += " older:${dateFormat.format(newDate)}";
      }
      else if( widget.queryFilters["date"] == widget.dateFilters[4] ) {
        // older than a year
        DateTime newDate = DateTime( today.year - 1, today.month, today.day, );
        queryString += " older:${dateFormat.format(newDate)}";
      }
    }

    // checking queryString is empty
    if( queryString.length == 2 ) {
      queryString = "{from: _}";
    }

    debugPrint("final QueryString - " + queryString );

    return queryString;
  }

  Future<void> _getEmailMessages( bool _breakLoop ) async {
    try {
      // checking if user has internet connection
      hasInternetConnection = await Utils.hasNetwork();

      if ( hasInternetConnection ) {
        String result = '' ;

        if ( queryString.isEmpty) {
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

  Future<void> refreshCurrentList( ) async {
    widget.queryStringBuilt = false;
    queryString = "";

    await _getEmailMessages(false);

    loadingMore = false;
    widget.loaded = false;
    widget.breakLoop = true;

    visibleMessages = {};

    currentIndex=0;
    await _getEmailMessages( true );
  }

  @override
  Widget build(BuildContext context) {
    if( widget.refreshList ) {
      widget.refreshList = false;
      refreshCurrentList();
    }

    const Key centerKey = ValueKey('second-sliver-list');

    // setting the super class's addToList and removeFromList methods
    widget.addElementToTop = addElementToTop;
    widget.removeElement = removeElement;

    int messagesLength = visibleMessages.length;

    return RefreshIndicator(
      onRefresh: refreshCurrentList,
      child: CustomScrollView(
        physics: messagesLength < 7 ? const AlwaysScrollableScrollPhysics( ) : _physics,
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
                  username: username,
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
                  username: username,
                );
              },
              childCount: messagesLength,
            ),
          ) : hasInternetConnection ?  widget.loaded ? SliverToBoxAdapter(
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
            child: Container(
              margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.25),
              alignment: Alignment.center,
              child: const Text("no internet connection"),
            ),
          ),
          loadingMore ? SliverToBoxAdapter(
            child: Container(
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width,
              height: 50,
              child: const CircularProgressIndicator.adaptive(),
            ),
          ): const SliverToBoxAdapter( ),
        ],
      ),
    );
  }
}
