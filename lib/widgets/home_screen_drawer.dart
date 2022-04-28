import 'package:flutter/material.dart';

import 'home_screen_drawer_tile.dart';

class HomeScreenDrawer extends StatefulWidget {
  final Function(int) notifyParent;
  final List<Widget> displayOptions;
  final Function(int) getBackgroundColor;
  Widget displayScreen;

  HomeScreenDrawer({Key? key, required this.displayScreen, required this.displayOptions, required this.notifyParent , required this.getBackgroundColor}) : super(key: key);

  @override
  _HomeScreenDrawerState createState() => _HomeScreenDrawerState();
}

class _HomeScreenDrawerState extends State<HomeScreenDrawer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width > 400 ? MediaQuery.of(context).size.width : 230 ,
      child: Drawer(
        backgroundColor: Colors.white,
        child: ListView(
          children: [
            SizedBox(
              height: 70,
              child: DrawerHeader(
                  child: Text(
                    'LetterShelf',
                    style: TextStyle(
                      fontSize: 25,
                      color: Color.fromRGBO(238, 26, 81, 1.0),
                    ),
                  )
              ),
            ),
            // Newsletters Header
            Padding(
              padding: EdgeInsets.only(left: 8,top: 10, bottom: 10),
              child: Text(
                "Newsletters",
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 18,
                    fontWeight: FontWeight.w300
                ),
              ),
            ),

            GestureDetector(
              onTap: () {
                widget.notifyParent( 0 );
                // widget.selectedDrawer = 0;

                setState(() { });
              },
              child: HomeScreenDrawerTile(
                foregroundColor: Color.fromRGBO(238, 26, 81, 1.0),
                backgroundColor: widget.getBackgroundColor(0),
                title: "Unread",
                iconLabel: Icons.mark_email_unread,
              ),
            ),
            GestureDetector(
              onTap: () {
                widget.notifyParent( 1 );
                // widget.selectedDrawer = 1;

                setState(() { });
              },
              child: HomeScreenDrawerTile(
                foregroundColor: Color.fromRGBO(238, 26, 81, 1.0),
                backgroundColor: widget.getBackgroundColor(1),
                title: "Read",
                iconLabel: Icons.mark_email_unread,
                iconColor: Colors.black45,
              ),
            ),
            GestureDetector(
              onTap: () {
                widget.notifyParent( 2 );
                // widget.selectedDrawer = 2;

                setState(() { });
              },
              child: HomeScreenDrawerTile(
                foregroundColor: Color.fromRGBO(238, 26, 81, 1.0),
                backgroundColor: widget.getBackgroundColor(2),
                title: "Saved",
                iconLabel: Icons.download_sharp,
              ),
            ),

            // All Mails Header
            Padding(
              padding: EdgeInsets.only(left: 8,top: 10),
              child: Text(
                "All Mails",
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 18,
                    fontWeight: FontWeight.w300
                ),
              ),
            ),

            GestureDetector(
              onTap: () {
                widget.notifyParent( 3 );
                // widget.selectedDrawer = 3;

                setState(() { });
              },
              child: HomeScreenDrawerTile(
                foregroundColor: Color.fromRGBO(238, 26, 81, 1.0),
                backgroundColor: widget.getBackgroundColor( 3 ),
                title: "Inbox",
              ),
            ),

            GestureDetector(
              onTap: () {
                widget.notifyParent( 4 );
                // widget.selectedDrawer = 4;

                setState(() { });
              },
              child: HomeScreenDrawerTile(
                foregroundColor: Color.fromRGBO(238, 26, 81, 1.0),
                title: "Important",
                backgroundColor: widget.getBackgroundColor( 4 ),
              ),
            ),

            GestureDetector(
              onTap: () {
                widget.notifyParent( 5 );
                // widget.selectedDrawer = 5;

                setState(() { });
              },
              child: HomeScreenDrawerTile(
                foregroundColor: Color.fromRGBO(238, 26, 81, 1.0),
                title: "Unread Mails",
                backgroundColor: widget.getBackgroundColor( 5 ),
              ),
            ),

            // All Labels Header
            Padding(
              padding: EdgeInsets.only(left: 8,top: 10),
              child: Text(
                "All Labels",
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 18,
                    fontWeight: FontWeight.w300
                ),
              ),
            ),

            GestureDetector(
              onTap: () {
                widget.notifyParent( 6 );
                // widget.selectedDrawer = 6;

                setState(() { });
              },
              child: HomeScreenDrawerTile(
                foregroundColor: Color.fromRGBO(238, 26, 81, 1.0),
                title: "Starred",
                backgroundColor: widget.getBackgroundColor( 6 ),
              ),
            ),

            GestureDetector(
              onTap: () {
                widget.notifyParent( 7 );
                // widget.selectedDrawer = 7;

                setState(() { });
              },
              child: HomeScreenDrawerTile(
                foregroundColor: Color.fromRGBO(238, 26, 81, 1.0),
                title: "Snoozed",
                backgroundColor: widget.getBackgroundColor( 7 ),
              ),
            ),

            GestureDetector(
              onTap: () {
                widget.notifyParent( 4 );
                // widget.selectedDrawer = 4;

                setState(() { });
              },
              child: HomeScreenDrawerTile(
                foregroundColor: Color.fromRGBO(238, 26, 81, 1.0),
                title: "Important",
                backgroundColor: widget.getBackgroundColor( 7 ),
              ),
            ),

            GestureDetector(
              onTap: () {
                widget.notifyParent( 8 );
                // widget.selectedDrawer = 8;

                setState(() { });
              },
              child: HomeScreenDrawerTile(
                foregroundColor: Color.fromRGBO(238, 26, 81, 1.0),
                title: "Sent",
                backgroundColor: widget.getBackgroundColor( 8 ),
              ),
            ),

            GestureDetector(
              onTap: () {
                widget.notifyParent( 9 );
                // widget.selectedDrawer = 9;

                setState(() { });
              },
              child: HomeScreenDrawerTile(
                foregroundColor: Color.fromRGBO(238, 26, 81, 1.0),
                title: "Scheduled",
                backgroundColor: widget.getBackgroundColor( 9 ),
              ),
            ),

            GestureDetector(
              onTap: () {
                widget.notifyParent( 10 );
                // widget.selectedDrawer = 10;

                setState(() { });
              },
              child: HomeScreenDrawerTile(
                foregroundColor: Color.fromRGBO(238, 26, 81, 1.0),
                title: "Outbox",
                backgroundColor: widget.getBackgroundColor( 10 ),
              ),
            ),

            GestureDetector(
              onTap: () {
                widget.notifyParent( 11 );
                // widget.selectedDrawer = 11;

                setState(() { });
              },
              child: HomeScreenDrawerTile(
                foregroundColor: Color.fromRGBO(238, 26, 81, 1.0),
                title: "Drafts",
                backgroundColor: widget.getBackgroundColor( 11 ),
              ),
            ),

            // Other  Header
            Padding(
              padding: EdgeInsets.only(left: 8,top: 10),
              child: Text(
                "Other",
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 18,
                    fontWeight: FontWeight.w300
                ),
              ),
            ),

            GestureDetector(
              onTap: () {
                widget.notifyParent( 12 );
                // widget.selectedDrawer = 12;

                setState(() { });
              },
              child: HomeScreenDrawerTile(
                foregroundColor: Color.fromRGBO(238, 26, 81, 1.0),
                title: "all Mails",
                backgroundColor: widget.getBackgroundColor( 12 ),
              ),
            ),

            GestureDetector(
              onTap: () {
                widget.notifyParent( 13 );
                // widget.selectedDrawer = 13;

                setState(() { });
              },
              child: HomeScreenDrawerTile(
                foregroundColor: Color.fromRGBO(238, 26, 81, 1.0),
                title: "Spam",
                backgroundColor: widget.getBackgroundColor( 13 ),
              ),
            ),

            GestureDetector(
              onTap: () {
                widget.notifyParent( 14 );
                // widget.selectedDrawer = 14;

                setState(() { });
              },
              child: HomeScreenDrawerTile(
                foregroundColor: Color.fromRGBO(238, 26, 81, 1.0),
                title: "Bin",
                backgroundColor: widget.getBackgroundColor( 14 ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
