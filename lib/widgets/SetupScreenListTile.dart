import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/subscribed_newsletters.dart';

class SetupScreenListTile extends StatefulWidget {
  final SubscribedNewsletter newsletter;

  const SetupScreenListTile({Key? key, required this.newsletter}) : super(key: key);

  @override
  _SetupScreenListTileState createState() => _SetupScreenListTileState();
}

class _SetupScreenListTileState extends State<SetupScreenListTile> {
  bool val = true;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Card(
        elevation: 5,
        child: ListTile(
          leading: const CircleAvatar(
            radius: 25,
            child: Text('A'),
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
