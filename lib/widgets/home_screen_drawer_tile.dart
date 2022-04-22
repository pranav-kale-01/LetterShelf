import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomeScreenDrawerTile extends StatefulWidget {
  final String title;

  const HomeScreenDrawerTile({Key? key, required this.title}) : super(key: key);

  @override
  _HomeScreenDrawerTileState createState() => _HomeScreenDrawerTileState();
}

class _HomeScreenDrawerTileState extends State<HomeScreenDrawerTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListTile(
        title: Row(
          children: [
            Icon( Icons.label ),
            Padding(
              padding: EdgeInsets.only(left: 16.0, ),
              child: Text(
                widget.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ) ,
              ),
            )
          ],
        ),
      ),
    );
  }
}