import 'package:flutter/material.dart';

import '../models/subscribed_newsletters.dart';
import '../utils/Utils.dart';

class SetupScreenListTile extends StatefulWidget {
  final SubscribedNewsletter newsletter;

  const SetupScreenListTile({Key? key, required this.newsletter}) : super(key: key);

  @override
  _SetupScreenListTileState createState() => _SetupScreenListTileState();
}

class _SetupScreenListTileState extends State<SetupScreenListTile> {
  bool val = true;
  late String initials;
  late Color backgroundColor;

  Color addIconColor = Colors.grey;
  Color textColor = Colors.black;
  IconData iconLogo = Icons.remove_circle_outline_sharp;

  // animation properties
  double turns = 0.0;
  bool isClicked = false;
  bool rotationAllowed = true;

  @override
  void initState() {
    super.initState();

    initials = Utils.getInitials(widget.newsletter.name);
    backgroundColor = Utils.getBackgroundColor(initials);
  }

  void rotate() {
    if( isClicked ) {
      setState(() {
        turns -= 1/2;
      });
    }
    else {
      setState(() {
        turns += 1/2;
      });
    }
    isClicked = !isClicked;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14)
        ),
        elevation: 8,
        child: ListTile(
          title: Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 2.0, right: 2.0, bottom: 0.0),
            child: Text(
              widget.newsletter.name,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 28.0,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only( left: 3.0, right: 3.0, top: 3.0, bottom: 8.0),
            child: Text(
              widget.newsletter.email,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w500,
                  color: textColor,
              ),
            ),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedRotation(
                curve: Curves.easeOutExpo,
                duration: const Duration( milliseconds: 600),
                turns: turns,
                child: GestureDetector(
                  onTap: () {
                    // rotating the button and changing the flag to avoid repetition
                    rotate();
                    rotationAllowed = !rotationAllowed;

                    setState(() {
                      // reversing the current value of the newsletter, means if it is enabled it would be disabled and vice versa
                      widget.newsletter.enabled = !widget.newsletter.enabled;
                      addIconColor = addIconColor == Colors.black ? Colors.grey : Colors.black;
                      textColor = textColor == Colors.black ? Colors.grey : Colors.black;
                      iconLogo = iconLogo == Icons.remove_circle_outline_sharp ? Icons.add : Icons.remove_circle_outline_sharp;
                    });
                  },
                  child: Icon(
                    iconLogo,
                    size: 32.0,
                    color: addIconColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
