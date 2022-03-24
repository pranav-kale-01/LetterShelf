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
            onTap: () async {
              launch(url);
              Navigator.of(context).pop();
            },
            child: const Text('Please go the following URL and grant access'),
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
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
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
                    ),
                  )),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.12,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.06,
              child: Material(
                elevation: 10,
                borderRadius: BorderRadius.circular(15),
                child: ElevatedButton(
                  style: ButtonStyle(
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
                      fontSize: 18,
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
