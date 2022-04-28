import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomeScreenDrawerTile extends StatelessWidget {
  final String title;
  final Color backgroundColor;
  final Color foregroundColor;
  IconData? iconLabel;
  Color? iconColor;

  HomeScreenDrawerTile({Key? key, required this.title, required this.backgroundColor, required this.foregroundColor, this.iconLabel, this.iconColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 5, top: 2, bottom: 2),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.horizontal(
          right: Radius.circular(20),
        )
      ),
      height: 50,
      child: ListTile(
        title: Row(
          children: [
            iconLabel == null ? Icon(
                Icons.label,
            ) : Icon(
                iconLabel!,
                color: backgroundColor == Colors.white ? iconColor == null ? Colors.black : iconColor! : foregroundColor,
            ),
            Padding(
              padding: EdgeInsets.only(left: 16.0),
              child: Text(
                title,
                style: TextStyle(
                  color: backgroundColor == Colors.white ? Colors.black : foregroundColor,
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