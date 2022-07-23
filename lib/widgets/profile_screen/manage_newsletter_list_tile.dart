import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:letter_shelf/models/subscribed_newsletters.dart';
import 'package:letter_shelf/utils/Utils.dart';


class ManageNewsletterListTile extends StatefulWidget {
  final SubscribedNewsletter newsletter;

  const ManageNewsletterListTile({Key? key, required this.newsletter}) : super(key: key);

  @override
  _ManageNewsletterListTileState createState() => _ManageNewsletterListTileState();
}

class _ManageNewsletterListTileState extends State<ManageNewsletterListTile> {
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
              style: const TextStyle(
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
