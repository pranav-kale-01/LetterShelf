import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:letter_shelf/models/subscribed_newsletters.dart';
import 'package:letter_shelf/screens/HomeScreen.dart';
import 'package:letter_shelf/screens/sign_in_screen.dart';
import 'package:letter_shelf/utils/google_user.dart';
import 'package:letter_shelf/utils/Utils.dart';
import 'package:letter_shelf/widgets/setup_screen/SetupScreenList.dart';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/gmail/v1.dart' as gmail;
import 'package:googleapis/people/v1.dart' as people;

class SetupScreen extends StatefulWidget {
  final GoogleSignInAccount user;
  final gmail.GmailApi? gmailApi;
  final people.PeopleServiceApi? peopleApi;

  const SetupScreen({Key? key, required this.user, required this.gmailApi, required this.peopleApi}) : super(key: key);

  @override
  SetupScreenState createState() => SetupScreenState();
}

class SetupScreenState extends State<SetupScreen> {
  // late gmail.GmailApi gmailApi;
  // late people.PeopleServiceApi peopleApi;
  late Future<void> loaded;

  List<SubscribedNewsletter> subscribedNewsletters = [];
  List<SubscribedNewsletter> allNewsletters = [];

  String nextButtonText = 'manually add later';
  double _progress=0;

  bool setupListLoadingComplete = false;
  bool signingOut = false;
  bool load= true;

  late Text displayText;
  late double textPadding;

  @override
  void initState() {
    super.initState();

    displayText = const Text('0%');
    textPadding = 0;

    loaded = loadGoogleApis();
  }

  Future<void> loadGoogleApis() async {
    // final authHeaders = await widget.user.authHeaders;
    // final authenticatedClient =  GoogleAuthClient( authHeaders );
    //
    // gmailApi = gmail.GmailApi(authenticatedClient);
    // peopleApi = people.PeopleServiceApi( authenticatedClient );
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
    gmail.Profile userProfile = await widget.gmailApi!.users.getProfile('me');
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
          user: widget.user,
          gmailApi: widget.gmailApi,
          peopleApi: widget.peopleApi,
        ),
      ),
    );
  }

  void updateProgress( double currentProgress ) {
    if( !signingOut ) {
      setState(() {
        textPadding = _progress;
        _progress = currentProgress;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        automaticallyImplyLeading: false,
        elevation: 0,
        actions: [
          GestureDetector(
            onTap: () async {
              // signing out
              signingOut = true;
              if( await signOutGoogle() ) {
                if( Navigator.canPop(context) ) {
                  Navigator.of(context).pop();
                }
                else {
                  Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => SignInScreen(
                          mediaQuery: mediaQuery,
                        ),
                      )
                  );
                }
              }
              else {
                // this part of the code would execute only if there is an issue signing out (for example, no internet connectivity)
                // if signing out fails we want to continue the processing of setting -up
                signingOut = false;
              }
            },
            child: Padding(
              padding: const EdgeInsets.only(left: 10.0, top: 0.0),
              child: Row(
                children: const [
                  Icon(
                      Icons.arrow_back_ios
                  ),
                  Text("Back")
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(),
          ),
        ],
      ),
      body: Container(
        alignment: Alignment.topCenter,
        child: Container(
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 30,
              ),
              Center(
                child: SizedBox(
                  height: 150,
                  width: 300,
                  child: setupListLoadingComplete ? SvgPicture.asset(
                    'assets/svg/mail_select.svg'
                  ) : Image.asset(
                      'assets/images/mail_search.png'
                  ),
                ),
              ),
              Container(
                width: mediaQuery.size.width * 0.9,
                padding: const EdgeInsets.only(left: 8, right: 8, top: 40, bottom: 14),
                child: Text(
                  setupListLoadingComplete
                      ? 'Pick you Readings List'
                      : 'Looking for the already present newsletters in your account..',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.start,
                ),
              ),
              if( !setupListLoadingComplete ) Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                height: 8,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: LinearProgressIndicator(
                    value: _progress,
                    backgroundColor: const Color.fromARGB(255, 252, 175, 203),
                    color: Colors.pinkAccent,
                  ),
                ),
              ),
              if( !setupListLoadingComplete ) SizedBox(
                width: MediaQuery.of(context).size.width,
                child: const Padding(
                  padding:
                  EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
                  child: Text(
                    'Loading..',
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
              Expanded(
                child: SetupScreenList(
                  api: widget.gmailApi!,
                  onLoadingComplete: onLoadingComplete,
                  subscribedNewsletters: subscribedNewsletters,
                  allNewsletters: allNewsletters,
                  onProgressed: updateProgress,
                  firstLoad: load,
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: const Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 0.0, horizontal: 6.0),
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
                                title: const Text('Are You Sure?'),
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
                                          fontSize: 16,
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
                                        fontSize: 16,
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
                            style: const TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.w700,
                            ),
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
