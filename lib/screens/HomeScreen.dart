import 'dart:io';

import 'package:flutter/material.dart';
import 'package:googleapis/gmail/v1.dart' as gmail;
import 'package:googleapis/people/v1.dart' as people;

import 'package:letter_shelf/screens/ExploreScreen.dart';
import 'package:letter_shelf/screens/InboxScreen.dart';
import 'package:letter_shelf/screens/ProfileScreen.dart';
import 'package:letter_shelf/widgets/HomeScreenList.dart';

import '../models/emailMessage.dart';
import '../widgets/home_screen_drawer.dart';
import '../widgets/mail_display_list.dart';
import '../widgets/saved_screen_list.dart';

class HomeScreen extends StatefulWidget {
  final gmail.GmailApi gmailApi;
  final people.PeopleServiceApi peopleApi;

  bool queryStringBuilt = false;

  HomeScreen({Key? key, required this.gmailApi, required this.peopleApi}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late String queryString;
  late List<Widget> homeScreenTabsList;
  int _selectedIndex =0;
  List<Widget> _pages = [];
  List<dynamic> cachedNewsletters = [];
  late BuildContext ctx;

  int selectedDrawer=0;
  Widget? mainScreen;
  late Widget currentDisplayScreen;
  bool firstTimeSearchTriggered = false;

  late AnimationController _controller;
  late Animation _animation;

  @override
  void initState() {
    super.initState();

    // animation for opening sidebar
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));

    _animation = Tween<double>(begin: 0, end: 20.0)
        .chain(CurveTween(curve: Curves.ease))
        .animate(_controller)
      ..addListener(() {
        setState(() {});
      });

    homeScreenTabsList = [
      HomeScreenList(
        key: const Key('UNREAD'),
        gmailApi: widget.gmailApi,
        queryStringAddOn: ' is:unread ',
        addToListMethod: addToHomeScreenList,
        removeFromListMethod: removeFromHomeScreenList,
      ),
      HomeScreenList(
        key: const Key('READ'),
        gmailApi: widget.gmailApi,
        queryStringAddOn: ' is:read ',
        addToListMethod: addToHomeScreenList,
        removeFromListMethod: removeFromHomeScreenList,
      ),
      SavedScreenList( ),
      MailDisplayList(
        key: const Key('INBOX'),
        gmailApi: widget.gmailApi,
        queryStringAddOn: ' is:inbox ',
        addToListMethod: addToHomeScreenList,
        removeFromListMethod: removeFromHomeScreenList,
      ),
      MailDisplayList(
        key: const Key('IMPORTANT'),
        gmailApi: widget.gmailApi,
        queryStringAddOn: ' is:important ',
        addToListMethod: addToHomeScreenList,
        removeFromListMethod: removeFromHomeScreenList,
      ),
      MailDisplayList(
        key: const Key('UNREAD MAILS'),
        gmailApi: widget.gmailApi,
        queryStringAddOn: ' is:unread ',
        addToListMethod: addToHomeScreenList,
        removeFromListMethod: removeFromHomeScreenList,
      ),
      MailDisplayList(
        key: const Key('STARRED'),
        gmailApi: widget.gmailApi,
        queryStringAddOn: ' is:starred ',
        addToListMethod: addToHomeScreenList,
        removeFromListMethod: removeFromHomeScreenList,
      ),
      MailDisplayList(
        key: const Key('SNOOZED'),
        gmailApi: widget.gmailApi,
        queryStringAddOn: ' is:snoozed ',
        addToListMethod: addToHomeScreenList,
        removeFromListMethod: removeFromHomeScreenList,
      ),
      MailDisplayList(
        key: const Key('SENT'),
        gmailApi: widget.gmailApi,
        queryStringAddOn: ' in:sent ',
        addToListMethod: addToHomeScreenList,
        removeFromListMethod: removeFromHomeScreenList,
      ),
      MailDisplayList(
        key: const Key('SCHEDULED'),
        gmailApi: widget.gmailApi,
        queryStringAddOn: ' in:scheduled ',
        addToListMethod: addToHomeScreenList,
        removeFromListMethod: removeFromHomeScreenList,
      ),
      MailDisplayList(
        key: const Key('OUTBOX'),
        gmailApi: widget.gmailApi,
        queryStringAddOn: ' is:outbox ',
        addToListMethod: addToHomeScreenList,
        removeFromListMethod: removeFromHomeScreenList,
      ),
      MailDisplayList(
        key: const Key('DRAFTS'),
        gmailApi: widget.gmailApi,
        queryStringAddOn: ' is:draft ',
        addToListMethod: addToHomeScreenList,
        removeFromListMethod: removeFromHomeScreenList,
      ),

      MailDisplayList(
        key: const Key('ALL MAILS'),
        gmailApi: widget.gmailApi,
        queryStringAddOn: ' ',
        addToListMethod: addToHomeScreenList,
        removeFromListMethod: removeFromHomeScreenList,
      ),

      MailDisplayList(
        key: const Key('SPAM'),
        gmailApi: widget.gmailApi,
        queryStringAddOn: ' in:spam ',
        addToListMethod: addToHomeScreenList,
        removeFromListMethod: removeFromHomeScreenList,
      ),

      MailDisplayList(
        key: const Key('BIN'),
        gmailApi: widget.gmailApi,
        queryStringAddOn: ' in:bin ',
        addToListMethod: addToHomeScreenList,
        removeFromListMethod: removeFromHomeScreenList,
      ),
    ];

    currentDisplayScreen = homeScreenTabsList[0];
  }

  void setNewScreen( int index ) {
    setState(() {
      selectedDrawer = index;
      currentDisplayScreen = homeScreenTabsList[index];
      mainScreen = currentDisplayScreen;

      // changing the inbox screen
      _pages[0] = InboxScreen(
        gmailApi: widget.gmailApi,
        topPadding: MediaQuery.of(context).padding.top,
        bottomPadding: MediaQuery.of(context).padding.bottom,
        scaffoldKey: _scaffoldKey,
        currentDisplayScreen: currentDisplayScreen,
        index: selectedDrawer,
      );

      firstTimeSearchTriggered = true;
    });

    _scaffoldKey.currentState!.openEndDrawer();
  }

  Future<void> addToHomeScreenList(
      {required String listName, required EmailMessage msg}) async {
    for (HomeScreenList homeScreenTab in homeScreenTabsList as List<HomeScreenList>) {
      if (homeScreenTab.key.toString() == listName) {
        // the correct list is found, adding the element to the top of the list
        homeScreenTab.addElementToTop(msg);
      }
    }
  }

  Future<void> removeFromHomeScreenList(
      {required String listName, required String msgId}) async {
    for (HomeScreenList homeScreenTab in homeScreenTabsList as List<HomeScreenList> ) {
      if (homeScreenTab.key.toString() == listName) {
        // the correct list is found, removing the element from the list
        homeScreenTab.removeElement(msgId);
      }
    }
  }

  Color getBackgroundColor(int index) {
    if( selectedDrawer == index ) {
      return const Color.fromRGBO(255, 70, 120, 0.4);
    }

    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    ctx = context;

    if( _pages.isEmpty ) {
      _pages = <Widget> [
        Transform.translate(
          offset: Offset( _animation.value, 0.0 ),
          child: InboxScreen(
            gmailApi: widget.gmailApi,
            topPadding: MediaQuery.of(context).padding.top,
            bottomPadding: MediaQuery.of(context).padding.bottom,
            scaffoldKey: _scaffoldKey,
            currentDisplayScreen: currentDisplayScreen,
            index: selectedDrawer,
          ),
        ),
        ExploreScreen(),
        ProfileScreen( gmailApi: widget.gmailApi, peopleApi: widget.peopleApi, bottomPadding: Platform.isAndroid ? kBottomNavigationBarHeight : 90, ),
      ];
    }

    return Transform.translate(
      offset: Offset( _animation.value, 0.0 ),
      child: Scaffold(
        key: _scaffoldKey,
        body: _pages[_selectedIndex],
        onDrawerChanged: (value) {
          if( value ) {
            _controller.forward();
          }
          else {
            _controller.reverse();
          }
        },
        drawerEnableOpenDragGesture: _selectedIndex == 0 ? true : false ,
        drawer: Transform.translate(
          offset: const Offset( -20.0, 0.0 ),
          child: HomeScreenDrawer(
            notifyParent: setNewScreen,
            displayOptions: homeScreenTabsList,
            getBackgroundColor: getBackgroundColor,
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          fixedColor: Colors.pinkAccent,
          items: const [
            BottomNavigationBarItem(
              label: "Inbox",
              icon: Icon(Icons.inbox),
            ),
            BottomNavigationBarItem(
              label: "Explore",
              icon: Icon(Icons.explore),
            ),
            BottomNavigationBarItem(
              label: "Profile",
              icon: Icon(Icons.person),
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: (int index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }
}
