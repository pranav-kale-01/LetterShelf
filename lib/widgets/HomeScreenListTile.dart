import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:googleapis/gmail/v1.dart' as gmail;
import 'package:letter_shelf/models/emailMessage.dart';

import 'MessageBody.dart';

class HomeScreenListTile extends StatefulWidget {
  final gmail.GmailApi gmailApi;
  final Function addToListMethod;
  final Function removeFromListMethod;
  final String listKey;
  EmailMessage emailMessage;
  Color headerColor = Colors.black;

  HomeScreenListTile({
    Key? key,
    required this.gmailApi,
    required this.emailMessage,
    required this.addToListMethod,
    required this.removeFromListMethod,
    required this.listKey,
  }) : super(key: key);

  @override
  _HomeScreenListTileState createState() => _HomeScreenListTileState();
}

class _HomeScreenListTileState extends State<HomeScreenListTile> {
  final monthData = {
    "1": "Jan",
    "2": "Feb",
    "3": "Mar",
    "4": "Apr",
    "5": "May",
    "6": "June",
    "7": "Jul",
    "8": "Aug",
    "9": "Sep",
    "10": "Oct",
    "11": "Nov",
    "12": "Dec"
  };

  late BuildContext ctx;
  bool executeOnTap = true;

  void loadMessage() {
    if (executeOnTap) {
      executeOnTap = false;
      _loadEmailMessageBody(
          widget.emailMessage.subject, widget.emailMessage.msgId);
    }
  }

  Future<void> _loadEmailMessageBody(
      String messageSubject, String messageId) async {
    Navigator.of(ctx).push(
      MaterialPageRoute(
        builder: (context) => MessageBody(
            api: widget.gmailApi,
            messageSubject: messageSubject,
            messageId: messageId),
      ),
    );

    executeOnTap = true;
  }

  @override
  Widget build(BuildContext context) {
    ctx = context;

    return GestureDetector(
      onTap: () {
        if (widget.listKey == "[<'UNREAD'>]") {
          setState(() {
            // setting the font color to light gray
            widget.headerColor = Colors.grey;

            // also changing the unread property of the current email message to false
            // (if we don't change the property, the next time ListTile is reloaded, there would be no way to tell if the message was read)
            widget.emailMessage.unread = false;

            // removing the message from unread and adding it to the top of read messages list
            // widget.removeFromListMethod( widget.emailMessage.msgId );
            // widget.addToListMethod( listName: 'UNREAD', msg: widget.emailMessage );

            // modifying the messages label to remove UNREAD Label from the message
            gmail.ModifyMessageRequest req = gmail.ModifyMessageRequest(
                removeLabelIds: [
                  "UNREAD"
                ]
            );

            widget.gmailApi.users.messages.modify( req, 'me', widget.emailMessage.msgId);
          });
        }
        loadMessage();
      },
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.15,
        child: Card(
          elevation: 5,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: CircleAvatar(
                  radius: 26,
                  child: Text('A'),
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.59,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding:
                          const EdgeInsets.only(top: 15, bottom: 5, left: 10),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        widget.emailMessage.from,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: widget.listKey == "[<'UNREAD'>]" && widget.emailMessage.unread ? widget.headerColor : Colors.grey,
                          fontWeight: FontWeight.w700,
                          fontSize: 22,
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(bottom: 20, top: 5, left: 10),
                      child: Text(
                        widget.emailMessage.subject,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        strutStyle: const StrutStyle(
                          height: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                alignment: Alignment.bottomCenter,
                padding:
                    const EdgeInsets.symmetric(horizontal: 2, vertical: 13),
                child: Text(
                    '${monthData[widget.emailMessage.date.month.toString()]} ${widget.emailMessage.date.day}'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
