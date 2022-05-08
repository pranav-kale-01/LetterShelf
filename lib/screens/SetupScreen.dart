import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:googleapis/gmail/v1.dart' as gmail;
import 'package:googleapis/people/v1.dart' as people;
import 'package:letter_shelf/screens/HomeScreen.dart';
import 'package:letter_shelf/screens/SelectAccount.dart';
import 'package:letter_shelf/widgets/SetupScreenList.dart';

import '../models/subscribed_newsletters.dart';
import '../utils/Utils.dart';

class SetupScreen extends StatefulWidget {
  final gmail.GmailApi gmailApi;
  final people.PeopleServiceApi peopleApi;

  const SetupScreen({Key? key, required this.gmailApi, required this.peopleApi}) : super(key: key);

  @override
  SetupScreenState createState() => SetupScreenState();
}

class SetupScreenState extends State<SetupScreen> {
  String nextButtonText = 'manually add later';
  bool setupListLoadingComplete = false;
  List<SubscribedNewsletter> subscribedNewsletters = [];
  List<SubscribedNewsletter> allNewsletters = [];
  bool load= true;
  double _progress=0;
  late Text displayText;
  late double textPadding;

  @override
  void initState() {
    displayText = Text('0%');
    textPadding = 0;

    super.initState();
  }

  void onLoadingComplete(List<SubscribedNewsletter> subscribedNewsletters) {
    setState(() {
      load = false;
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
      // if (newsletter.enabled) {
        jsonList.add({
          "name": newsletter.name,
          "email": newsletter.email,
          "enabled": newsletter.enabled
        });
      // }
    }

    // writing the json into newsletter-list file
    final path = (await Utils.localPath).path;
    final username = await getCurrentUserName();

    // File name will be newsletterlist_<Current User Email>.json
    File file = File( '$path/newsletterslist_' + username + '.json');
    await file.create();

    file.writeAsString(json.encode(jsonList));

    // redirecting the user to the home screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => HomeScreen(
          gmailApi: widget.gmailApi,
          peopleApi: widget.peopleApi,
        ),
      ),
    );
  }

  void updateProgress( double currentProgress ) {
    setState(() {
      displayText = new Text('${_progress.toInt()}%');
      textPadding = _progress;
      _progress = currentProgress;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                elevation: MaterialStateProperty.all<double>(0),
              ) ,
              onPressed: () {},
              child: Container(
                child: IconButton(
                  color: Colors.black,
                  icon: const Icon(Icons.logout),
                  onPressed: () async {
                    final path = (await Utils.localPath).path;
                    final file = File(path + '/currentUser.json');

                    // resetting all the flags for the new user
                    Utils.firstProfileScreenLoad = true;
                    Utils.firstHomeScreenLoadRead = true;
                    Utils.firstHomeScreenLoadUnread = true;

                    file.delete();

                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const SelectAccount(),
                      ),
                    );
                  },
                ),
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
                padding: const EdgeInsets.only(left: 10, right: 10, top: 30, bottom: 25),
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
              if( !setupListLoadingComplete ) Container(
                padding: EdgeInsets.symmetric(horizontal: 12),
                height: 20,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: LinearProgressIndicator(
                    value: _progress,

                  ),
                ),
              ),
              // if( !setupListLoadingComplete) Container(
              //   margin: EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              //   width: MediaQuery.of(context).size.width,
              //   padding: EdgeInsets.only(left: textPadding),
              //   child: displayText,
              // ),
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
                    allNewsletters: allNewsletters,
                    onProgressed: updateProgress,
                    firstLoad: load,
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
                                title: Text('Are You Sure?'),
                                content: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: const <Widget>[

                                      Text('You Have to manually add later, the newsletters you want'),
                                    ],
                                  ),
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    child: const Text(
                                        'Cancel',
                                        style: TextStyle(
                                          fontSize: 18,
                                        ),
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  TextButton(
                                    child: const Text(
                                      'Continue',
                                      style: TextStyle(
                                        fontSize: 28,
                                      ),
                                    ),
                                    onPressed: () {
                                      saveNewsletters();
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
