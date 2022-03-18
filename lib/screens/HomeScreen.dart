import 'dart:io';

import 'package:flutter/material.dart';
import 'package:googleapis/gmail/v1.dart' as gmail;
import 'package:letter_shelf/models/emailMessage.dart';
import 'package:letter_shelf/screens/ExploreScreen.dart';
import 'package:letter_shelf/screens/InboxScreen.dart';
import 'package:letter_shelf/screens/ProfileScreen.dart';
import 'package:letter_shelf/screens/SelectAccount.dart';
import 'package:letter_shelf/widgets/HomeScreenList.dart';

import '../utils/Utils.dart';

class HomeScreen extends StatefulWidget {
  final gmail.GmailApi gmailApi;
  bool queryStringBuilt = false;

  HomeScreen({Key? key, required this.gmailApi}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with AutomaticKeepAliveClientMixin {
  late String queryString;
  late List<HomeScreenList> homeScreenTabsList;
  int _selectedIndex =0;
  List<Widget> _pages = [];
  late AppBar appbar;


  @override
  void initState() {
    appbar = AppBar(
      title: const Text('LetterShelf'),
      backgroundColor: Colors.white,
      elevation: 0,
      titleTextStyle: const TextStyle(
        color: Colors.black,
        fontSize: 22
      ) ,
      actions: [
        IconButton(
          onPressed: () async {
            final path = (await Utils.localPath).path;
            final file = File(path + '/currentUser.json');
            file.delete();

            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const SelectAccount(),
              ),
            );
          },
          icon: const Icon(
            Icons.logout,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint( _pages.length.toString() );
    if( _pages.length == 0 ) {
      _pages = <Widget> [
        InboxScreen(gmailApi: widget.gmailApi, appBarHeight: appbar.preferredSize.height, topPadding: MediaQuery.of(context).padding.top, bottomPadding: MediaQuery.of(context).padding.bottom,),
        ExploreScreen(),
        ProfileScreen(),
      ];
    }

    return Scaffold(
      appBar: appbar,
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
