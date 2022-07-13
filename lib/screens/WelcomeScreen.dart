import 'package:flutter/material.dart';
import 'package:letter_shelf/screens/SetupScreen.dart';

import 'package:googleapis/gmail/v1.dart' as gmail;
import 'package:googleapis/people/v1.dart' as people;

class WelcomeScreen extends StatelessWidget {
  final gmail.GmailApi gmailApi;
  final people.PeopleServiceApi peopleApi;

  const WelcomeScreen({Key? key, required this.gmailApi, required this.peopleApi }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
          alignment: Alignment.center,
          child: ElevatedButton(
            child: const Text("Welcome"),
            onPressed: () async {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => SetupScreen( gmailApi: gmailApi, peopleApi: peopleApi ),
                ),
              );
            },
          )),
    );
  }
}
