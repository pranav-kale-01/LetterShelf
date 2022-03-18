import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:googleapis/gmail/v1.dart' as gmail;
import 'package:http/http.dart' as http;
import 'package:letter_shelf/models/subscribed_newsletters.dart';
import 'package:letter_shelf/widgets/SetupScreenListTile.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../firebase_operations/firebase_utils.dart';

// ignore: must_be_immutable
class SetupScreenList extends StatefulWidget {
  final gmail.GmailApi api;
  bool loaded = false;
  bool breakLoop = false;
  int uniqueItems = 0;
  int count = 0;
  List<SubscribedNewsletter> subscribedNewsletters;
  final Function onLoadingComplete;

  SetupScreenList(
      {Key? key,
      required this.api,
      required this.onLoadingComplete,
      required this.subscribedNewsletters})
      : super(key: key);

  @override
  _SetupScreenListState createState() => _SetupScreenListState();
}

class _SetupScreenListState extends State<SetupScreenList> {
  Map<String, String> subscribedEmails = {};
  List<Widget> listOfSubscribedEmails = [];
  List<String> msgIds = [];
  bool loadingComplete = false;

  void callOnLoad(Function methodToCall) {
    Future.delayed(const Duration(milliseconds: 1000), () async {
      if (!widget.loaded) {
        widget.loaded = true;
        await methodToCall();
      }
    });
  }

  Future<void> loadSubscribedEmailAccounts() async {
    Map<String, String> unSubscribedEmails = {};

    if (loadingComplete) {
      return;
    }

    try {
      gmail.ListMessagesResponse clientMessages =
          await widget.api.users.messages.list('me', maxResults: 50);

      // creating a reference of firebase db
      FirebaseFirestore db = FirebaseFirestore.instance;

      // showing the list of available newsletter emails
      FirebaseUtils utils = FirebaseUtils( db: db );

      List<dynamic> data = await utils.getData();

      // // getting a list of subscribed emails from the server database
      // const String url =
      //     "https://test-pranav-kale.000webhostapp.com/scripts/newsletter_app/getNameAndEmails.php?table=newsletters_list&condition=";
      // http.Response response = await http.get(Uri.parse(url));
      //
      // debugPrint(response.body);
      //
      // List<dynamic> data = jsonDecode(response.body);

      Map<String, String> serverList = {};

      for (var i in data) {
        Map<String, dynamic> decodedData = jsonDecode(i);
        serverList.addAll({decodedData['newsletter_name']: decodedData['email']});
      }

      // debugPrint( serverList.toString() );

      List<String> tempMsgIds = clientMessages.messages!.map((message) {
        return message.id.toString();
      }).toList();

      for (String msgId in tempMsgIds) {
        gmail.Message msg = await widget.api.users.messages.get('me', msgId, format: "metadata");
        List<gmail.MessagePartHeader>? headers = msg.payload?.headers;

        for (gmail.MessagePartHeader header in headers!) {
          // debugPrint( header.name.toString() + ' - ' + header.value.toString() );

          if (header.name == "From") {
            String value = '${header.value}';

            // splitting the string to get the email from the value
            int startIndex = value.indexOf('<');

            // if startIndex == -1, the email is not properly formatted
            // if startIndex == 0, the sender does not have a name linked to the email (most likely a email from a banking firm)
            if (startIndex > 0 ) {
              String email = value.substring(startIndex + 1, (value.length - 1));
              String name = value.substring(0, startIndex - 1);

              // checking if the sender is already added to the subscribedList or unSubscribedList
              if (!(subscribedEmails[name] == email) &&
                  !(unSubscribedEmails[name] == email)) {
                // checking if there is an entry of this email in the server list
                if (serverList.containsKey(name) && serverList.containsValue(email)) {
                  setState(() {
                    if (subscribedEmails[name] != email) {
                      subscribedEmails.addAll({name: email});
                      widget.subscribedNewsletters.add(SubscribedNewsletter(name: name, email: email));
                    }

                    widget.uniqueItems += 1;
                  });
                } else {
                  unSubscribedEmails.addAll({name: email});
                  widget.uniqueItems += 1;
                }
              }
            }
          }

          if (widget.breakLoop) {
            return;
          }
        } // headers loop ends here
        widget.count++;
      } // messages loop ends here

      loadingComplete = true;
      widget.onLoadingComplete(widget.subscribedNewsletters);
    } catch (e, stacktrace) {

      debugPrint( "SetupScreenList - " + e.toString() + "\n" + stacktrace.toString());
    }
  }


  @override
  Widget build(BuildContext context) {
    callOnLoad(loadSubscribedEmailAccounts);
    return Padding(
      padding: const EdgeInsets.all(4),
      child: ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          // return SetupScreenListTile(msgTitle:  subscribedEmails.keys.toList()[index] , msgSubject: subscribedEmails.values.toList()[index],);
          return SetupScreenListTile(
            newsletter: widget.subscribedNewsletters[index],
          );
        },
        itemCount: widget.subscribedNewsletters.length,
      ),
    );
  }

  @override
  void dispose() {
    widget.breakLoop = true;
    super.dispose();
  }
}
