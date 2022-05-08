import 'dart:io';

import 'package:flutter/material.dart';
import 'package:googleapis/gmail/v1.dart' as gmail;
import 'package:googleapis/people/v1.dart' as people;
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:letter_shelf/widgets/SelectAccountListTile.dart';

import 'package:url_launcher/url_launcher.dart';

import '../screen_loaders/newsletterslistCheckLoader.dart';
import '../utils/OAuthClient.dart';
import '../utils/Utils.dart';

class SelectAccount extends StatefulWidget {
  const SelectAccount({Key? key}) : super(key: key);

  @override
  _SelectAccountState createState() => _SelectAccountState();
}

class _SelectAccountState extends State<SelectAccount> {
  List<String> allAccounts = [];
  bool loaded = false;

  late gmail.GmailApi gmailApi;
  late people.PeopleServiceApi peopleApi;
  late http.Client client;

  void callOnLoad(Function methodToCall) {
    Future.delayed(const Duration(milliseconds: 1000), () async {
      if (!loaded) {
        loaded = true;
        await methodToCall();
      }
    });
  }

  Future<void> getAllUserAccounts() async {
    // using regular expression to check if there is any file with credentials_<User Account Name>.json
    final directory = await Utils.localPath;
    final re = RegExp(r'credentials_');
    List<FileSystemEntity> files = directory.listSync();

    for (FileSystemEntity ent in files) {
      final filename = ent.toString();
      final match = re.firstMatch(filename);

      if (match != null) {
        // adding the user account to the list of all accounts
        setState(() {
          allAccounts.add(filename.substring(match.end, filename.length - 6));
        });
      }
    }
  }

  // prompt for user to sign-in using the consent Screen
  void _prompt(String url, BuildContext ctx) {
    showDialog(
      context: ctx,
      builder: (BuildContext context) {
        return Dialog(
          child: GestureDetector(
            child: Container(
                padding: EdgeInsets.symmetric(horizontal: 22),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only( top: 16.0, bottom: 24),
                      child: Text(
                          "Google Sign In",
                          style: TextStyle(
                            fontSize: 26,
                          ),
                      ),
                    ),
                    Text(
                        'Please go the following URL to Sign in with your Google Account',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Container(
                      height: 2,
                      color: Colors.black12,
                    ),
                    GestureDetector(
                      onTap: () async {
                        launch(url);
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        padding: EdgeInsets.only(right: 8.0,top: 12),
                        alignment: Alignment.center,
                        child: Text(
                            'Open Link',
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 22,
                              fontWeight: FontWeight.w500
                            ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    callOnLoad(getAllUserAccounts);
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8.0,  right: 8.0, top: 40,),
              child: Text(
                "Select a account to Sign in",
                style: TextStyle(
                  fontSize: 36,
                ),
              ),
            ),
            SizedBox(
              height: 80,
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: SizedBox(
                    // height: MediaQuery.of(context).size.height - 400,
                    child: SingleChildScrollView(
                      child: Column(
                        // mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: allAccounts.map((value) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      NewsletterslistCheckLoader(
                                          username: value),
                                ),
                              );
                            },
                            child: SelectAcccountListTile(username: value),
                          );
                        }).toList(),
                      ),
                    )),
              ),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 10),
              width: MediaQuery.of(context).size.width * 0.95,
              height: 60,
              child: Material(
                elevation: 10,
                borderRadius: BorderRadius.circular(15),
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.pinkAccent),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                  onPressed: () async {
                    OAuthClient _client = OAuthClient(username: '');
                    bool successful = await _client.obtainCredentials( context: context, prompt: _prompt);

                    if (successful) {
                      // getting the autoRefreshingClient
                      String userName = await _client.getCurrentUserName();

                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => NewsletterslistCheckLoader(
                            username: userName,
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text(
                    'Sign in With Other Account',
                    style: TextStyle(
                      fontSize: 21,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
