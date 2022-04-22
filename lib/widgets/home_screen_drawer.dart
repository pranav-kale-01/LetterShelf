import 'package:flutter/material.dart';

import 'home_screen_drawer_tile.dart';

class HomeScreenDrawer extends StatelessWidget {
  Widget displayScreen;
  final Function(int) notifyParent;
  final List<Widget> displayOptions;

  HomeScreenDrawer({Key? key, required this.displayScreen, required this.displayOptions, required this.notifyParent }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width > 400 ? MediaQuery.of(context).size.width : 230 ,
      child: Drawer(
        child: ListView(
          children: [
            SizedBox(
              height: 70,
              child: DrawerHeader(
                child: Text(
                    'LetterShelf',
                    style: TextStyle(
                      fontSize: 25,
                      color: Color.fromRGBO(255, 70, 120, 1),
                    ),
                )
              ),
            ),
            GestureDetector(
                onTap: () {
                  notifyParent( 0 );
                },
                child: HomeScreenDrawerTile(title: "Unread"),
            ),
            GestureDetector(
                onTap: () {
                  notifyParent( 1 );
                },
                child: HomeScreenDrawerTile( title: "Read"),
            ),
            HomeScreenDrawerTile(title: "Saved",),
          ],
        ),
      ),
    );
  }
}
