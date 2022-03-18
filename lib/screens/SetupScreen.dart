import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:googleapis/gmail/v1.dart' as gmail;
import 'package:letter_shelf/screens/HomeScreen.dart';
import 'package:letter_shelf/screens/SelectAccount.dart';
import 'package:letter_shelf/widgets/SetupScreenList.dart';

import '../models/subscribed_newsletters.dart';
import '../utils/Utils.dart';

class SetupScreen extends StatefulWidget {
  final gmail.GmailApi gmailApi;

  const SetupScreen({Key? key, required this.gmailApi}) : super(key: key);

  @override
  SetupScreenState createState() => SetupScreenState();
}

class SetupScreenState extends State<SetupScreen> {
  String nextButtonText = 'manually add later';
  bool setupListLoadingComplete = false;
  List<SubscribedNewsletter> subscribedNewsletters = [];

  void onLoadingComplete(List<SubscribedNewsletter> subscribedNewsletters) {
    setState(() {
      this.subscribedNewsletters = subscribedNewsletters;
      setupListLoadingComplete = true;
      nextButtonText = 'continue';
    });
  }

  Future<String> getCurrentUserName() async {
    gmail.Profile userProfile = await widget.gmailApi.users.getProfile('me');
    return userProfile.emailAddress!;
  }

  Future<void> saveNewsletters() async {
    // creating a json for all the selected newsletters
    List<Map<String, dynamic>> jsonList = [];

    // adding a json with user name first (for multi-account support)
    jsonList.add({"user_email": await getCurrentUserName()});

    // adding all the selected newsletters
    for (SubscribedNewsletter newsletter in subscribedNewsletters) {
      if (newsletter.enabled) {
        jsonList.add({
          "name": newsletter.name,
          "email": newsletter.email
        });
      }
    }

    // writing the json into newsletter-list file
    final path = (await Utils.localPath).path;
    final username = await getCurrentUserName();

    // File name will be newsletterlist_<Current User Email>.json
    File file = File(
        '$path/newsletterslist_' + username + '.json');
    await file.create();

    file.writeAsString(json.encode(jsonList));

    // redirecting the user to the home screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => HomeScreen(
          gmailApi: widget.gmailApi,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          ElevatedButton(
              onPressed: () {},
              child: IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  final path = (await Utils.localPath).path;
                  final file = File(path + '/currentUser.json');
                  file.delete();

                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const SelectAccount(),
                    ),
                  );
                },
              ))
        ],
      ),
      body: Container(
        alignment: Alignment.center,
        child: Container(
          width: MediaQuery.of(context).size.width / 1,
          // height: MediaQuery.of(context).size.height / 1.7,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          child: Column(
            mainAxisAlignment: setupListLoadingComplete
                ? MainAxisAlignment.start
                : MainAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.only(left: 10, right: 10, top: 30),
                child: Text(
                  setupListLoadingComplete
                      ? 'Select which newsletters you want to read'
                      : 'Looking for newsletters in your account..',
                  style: const TextStyle(
                    fontSize: 26,
                  ),
                  textAlign: setupListLoadingComplete
                      ? TextAlign.start
                      : TextAlign.center,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  margin: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(7),
                    color: Colors.black12,
                  ),
                  height: MediaQuery.of(context).size.height / 2.210,
                  width: MediaQuery.of(context).size.width / 1,
                  child: SetupScreenList(
                    api: widget.gmailApi,
                    onLoadingComplete: onLoadingComplete,
                    subscribedNewsletters: subscribedNewsletters,
                  ),
                ),
              ),
              if (setupListLoadingComplete)
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: const Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 8.0, horizontal: 6.0),
                    child: Text(
                      'You can always add more newsletters from the marketplace',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: MediaQuery.of(context).size.height * 0.02,
                      horizontal: MediaQuery.of(context).size.height * 0.015,
                    ),
                    child: GestureDetector(
                      onTap: () async {
                        // if loading not completed and user wants to add later, ask for confirmation
                        if( !setupListLoadingComplete ) {
                          return showDialog<void>(
                            context: context,
                            barrierDismissible: false, // user must tap button!
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('AlertDialog Title'),
                                content: SingleChildScrollView(
                                  child: Column(
                                    children: const <Widget>[
                                      Text('Are You Sure?'),
                                      Text('You Have to manually add later, the newsletters you want?'),
                                    ],
                                  ),
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    child: const Text('Continue'),
                                    onPressed: () {
                                      debugPrint('Confirmed');
                                      saveNewsletters();
                                    },
                                  ),
                                  TextButton(
                                    child: const Text('Cancel'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        }
                        else {
                          // loading process is completed, continue without prompting
                          saveNewsletters();
                        }

                        // if (setupListLoadingComplete) {
                          // saveNewsletters();
                        // } else {
                          // debugPrint(subscribedNewsletters.length.toString());
                        // }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            setupListLoadingComplete
                                ? 'continue'
                                : 'add more later',
                            textAlign: TextAlign.end,
                          ),
                          const Icon(
                            Icons.arrow_forward_ios_sharp,
                          )
                        ],
                      ),
                    )),
              )
            ],
          ),
        ),
      ),
    );
  }
}
