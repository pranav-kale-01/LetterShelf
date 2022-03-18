import 'package:flutter/material.dart';
import 'package:letter_shelf/screens/SetupScreen.dart';
import 'package:googleapis/gmail/v1.dart' as gmail;

class WelcomeScreen extends StatelessWidget {
  final gmail.GmailApi api;

  const WelcomeScreen({Key? key, required this.api }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          alignment: Alignment.center,
          child: ElevatedButton(
            child: const Text("Welcome"),
            onPressed: () async {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => SetupScreen( gmailApi: api ),
                ),
              );
            },
          )),
    );
  }
}
