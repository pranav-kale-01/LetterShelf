import 'dart:io';

import 'package:flutter/material.dart';
import 'package:googleapis/gmail/v1.dart' as gmail;
import 'package:googleapis/people/v1.dart' as people;

import 'package:letter_shelf/screens/ExploreScreen.dart';
import 'package:letter_shelf/screens/InboxScreen.dart';
import 'package:letter_shelf/screens/ProfileScreen.dart';
import 'package:letter_shelf/widgets/HomeScreenList.dart';

class HomeScreen extends StatefulWidget {
  final gmail.GmailApi gmailApi;
  final people.PeopleServiceApi peopleApi;

  bool queryStringBuilt = false;

  HomeScreen({Key? key, required this.gmailApi, required this.peopleApi}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with AutomaticKeepAliveClientMixin {
  late String queryString;
  late List<HomeScreenList> homeScreenTabsList;
  int _selectedIndex =0;
  List<Widget> _pages = [];
  List<dynamic> cachedNewsletters = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if( _pages.isEmpty ) {
      _pages = <Widget> [
        InboxScreen(gmailApi: widget.gmailApi, topPadding: MediaQuery.of(context).padding.top, bottomPadding: MediaQuery.of(context).padding.bottom,),
        ExploreScreen(),
        ProfileScreen( gmailApi: widget.gmailApi, peopleApi: widget.peopleApi, bottomPadding: Platform.isAndroid ? kBottomNavigationBarHeight : 90, ),
      ];
    }

    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
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
    );
  }

  @override
  bool get wantKeepAlive => true;
}
