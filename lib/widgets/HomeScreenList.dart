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

  bool refreshed = false;
  bool loadingMore = false;

  final HiveServices hiveService = HiveServices( );

  int currentIndex = 0;
  int maxResults = 500;
  bool executeOnTap = true;
  late String username;
  ScrollPhysics _physics = ClampingScrollPhysics();

  late List<EmailMessage> top = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    controller = ScrollController()..addListener(handleBottomListScrolling);
    widget.queryStringBuilt = false;
    myFuture = init();
  }

  Future<void> init() async {
    // first creating a logged in user account, to indicate that the sign up process was successful
    CreateLoggedinUser(api: widget.gmailApi);

    // getting username
    username = await OAuthClient.getCurrentUserNameFromApi(widget.gmailApi);

    // opening Hive Box
    await hiveService.openHiveBox( widget.queryStringAddOn + "CachedMessages" + username );

    await _getEmailMessages( false );
  }

  void handleBottomListScrolling() {
    // if the list has been scrolled down to the end
    if (controller.position.maxScrollExtent == controller.offset) {
      if (!loadingMore) {
        setState(() {

          controller.animateTo(controller.position.maxScrollExtent,
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutExpo);
        });
        loadingMore = true;

        _loadEmailMessages(
            currentIndex + 10 > tempMsgIds.length ? tempMsgIds.length -
                currentIndex : currentIndex + 10);
      }
    }

    if (controller.position.pixels <= 56) {
      if( controller.position.pixels < 0 ) {
        controller.jumpTo(0);
      }
      setState(() => _physics = ClampingScrollPhysics());
    }
    else {
      setState(() => _physics = BouncingScrollPhysics());
    }

  }

  Future<void> _loadEmailMessages(int limit) async {
    try {
      List<dynamic> cacheList = [];


      if (widget.loaded) {
        return;
      }

      setState(() {
        widget.loaded = true;
      });

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
              unread: widget.queryStringAddOn == " is:unread " ? true : false,
          );

          cacheList.add(msg.toJson());
          visibleMessages.addAll({tempMsgIds.elementAt(currentIndex): msg});

          currentIndex += 1;
        }
      }

      // adding json to hive for caching
      await hiveService.addBoxes( cacheList, widget.queryStringAddOn + "CachedMessages" + username );

      setState(() {
        loadingMore = false;
        widget.loaded = false;
      });
    }
    catch( e, stacktrace ) {
      debugPrint( e.toString() );
      debugPrint( stacktrace.toString() );

      loadingMore = false;
      widget.loaded = false;
    }
  }

  Future<String> _createQueryString() async {
    if (widget.queryStringBuilt) {
      return '';
    }

    // loading the newsletters file from memory
    final localPath = await Utils.localPath;
    final String username = await OAuthClient.getCurrentUserNameFromApi(widget.gmailApi);

    final File newslettersFile = File(localPath.path + '/newsletterslist_' + username + '.json');

    // reading the file
    List<dynamic> jsonList = jsonDecode(await newslettersFile.readAsString());

    String queryString = '{';

    for (var json in jsonList) {
      if (json['email'] != null ) {
        if(  json['enabled'] == true) {
          queryString += 'from: "' + json['name'] + '" ';
        }
      }
    }
    queryString += '}';

    // checking queryString is empty
    if( queryString.length == 2 ) {
      queryString = "{from: _}";
    }

    widget.queryStringBuilt = true;
    return queryString;
  }

  Future<void> _getEmailMessages( bool _breakLoop ) async {
    try {
      // checking if email messages are already cached
      bool exists = await hiveService.isExists(boxName: widget.queryStringAddOn + "CachedMessages" + username );

      if ( ( !(widget.queryStringAddOn == 'unread' ? Utils.firstHomeScreenLoadUnread : Utils.firstHomeScreenLoadRead) && exists ) ) {
        List<dynamic> tempList = await hiveService.getBoxes( widget.queryStringAddOn + "CachedMessages" + username );

        for( var msg in tempList ) {
         setState(() {
           // creating string for from field
           String _from = "${msg['from']} <${msg['emailId']}>";

           // creating an object of EmailMessage
           EmailMessage _msg = EmailMessage(
               msgId: msg['msgId'],
               from: _from,
               date: msg['date'],
               subject: msg['subject'],
               image: msg['image'],
               unread: msg['unread']
           );

           currentIndex += tempList.length;
           visibleMessages.addAll( {msg['msgId'] : _msg} );
         });
        }

        widget.queryStringAddOn == 'unread' ? Utils.firstHomeScreenLoadUnread : Utils.firstHomeScreenLoadRead = false;

        String result = '' ;

        if ( queryString.isEmpty ) {
          queryString = await _createQueryString();
        }

        result = queryString;

        gmail.ListMessagesResponse clientMessages = await widget.gmailApi.users.messages.list('me', maxResults: maxResults, q: widget.queryStringAddOn + result );

        if( clientMessages.messages == null ) {
          return;
        }

        tempMsgIds = clientMessages.messages!.map((message) {
          return message.id.toString();
        }).toSet();

        _loadEmailMessages( currentIndex + 7 < maxResults ? currentIndex + 7 : maxResults - 1 );
      }
      else {
        // removing the current box from hive ( so the messages from api are loaded instead of the cached messages )
        // getting required box
        Box _box = await Hive.openBox( widget.queryStringAddOn + "CachedMessages" + username );

        _box.deleteAll(_box.keys);

        widget.queryStringAddOn == 'unread' ? Utils.firstHomeScreenLoadUnread : Utils.firstHomeScreenLoadRead = false;

        String result = '' ;

        if ( queryString.isEmpty ) {
          queryString = await _createQueryString();
        }

        result = queryString;

        gmail.ListMessagesResponse clientMessages = await widget.gmailApi.users.messages.list('me', maxResults: maxResults, q: widget.queryStringAddOn + result );

        if( clientMessages.messages == null ) {
          return;
        }

        tempMsgIds = clientMessages.messages!.map((message) {
          return message.id.toString();
        }).toSet();

        if( _breakLoop ) {
          widget.breakLoop = false;
        }

        _loadEmailMessages( tempMsgIds.length < 7 ? tempMsgIds.length : 7 );
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
    // EmailMessage msg = visibleMessages[msgId];

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
      onRefresh: ( ) async {
        if( !refreshed ) {
          refreshed = true;
          return;
        }

        Future.delayed(const Duration(milliseconds: 100), () async {
          setState(() {
            loadingMore = false;
            widget.loaded = false;
          });

          widget.queryStringAddOn == 'unread' ? Utils.firstHomeScreenLoadUnread : Utils.firstHomeScreenLoadRead = true;
          widget.breakLoop = true;

          setState(() {
            widget.queryStringBuilt = false;
            visibleMessages = {};
          });

          currentIndex=0;
          await _getEmailMessages( true );
        });
      },
      child: CustomScrollView(
        physics: messagesLength < 7 ?  AlwaysScrollableScrollPhysics( ) : _physics ,
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
                  username: username
                );
              },
              childCount: messagesLength,
            ),
          ) : widget.loaded == false ? SliverToBoxAdapter(
              key: centerKey,
              child: Container(
                  margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.25),
                  alignment: Alignment.center,
                  child: const Text("no current messages"),
              ),
          ) : SliverToBoxAdapter(
            key: centerKey,
            child: Container(
              margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.25),
              alignment: Alignment.center,
              child: const CircularProgressIndicator(),
            ),
          ),
          loadingMore ? SliverToBoxAdapter(
            child: Container(
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width,
              height: 50,
              child: CircularProgressIndicator.adaptive(),
            ),
          ) : const SliverToBoxAdapter(),
        ],
      ),
    );
  }
}
