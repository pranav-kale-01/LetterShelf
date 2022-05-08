import 'package:flutter/cupertino.dart';
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

  @override
  void initState() {
    super.initState();

    initials = Utils.getInitials(widget.newsletter.name);
    backgroundColor = Utils.getBackgroundColor(initials);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Card(
        elevation: 5,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: backgroundColor,
            radius: 25,
            child: Text(
                initials,
                style: TextStyle(
                  color: Colors.white,
                ),
            ),
          ),
          title: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
            child: Text(
              widget.newsletter.name,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 3.0),
            child: Text(
              widget.newsletter.email,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          trailing: Transform.scale(
            scale: 0.9,
            child: CupertinoSwitch(
                value: widget.newsletter.enabled,
                onChanged: (value) {
                  setState(() {
                    widget.newsletter.enabled = value;
                  });
                }),
          ),
        ),
      ),
    );
  }
}
