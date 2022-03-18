import 'package:flutter/material.dart';
import 'package:googleapis/gmail/v1.dart' as gmail;
import 'package:http/http.dart' as http;
import 'package:letter_shelf/screens/WelcomeScreen.dart';
import 'package:letter_shelf/utils/OAuthClient.dart';
import 'package:url_launcher/url_launcher.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  late gmail.GmailApi gmailApi;
  late http.Client client;

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
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: ElevatedButton(
          onPressed: () async {
            OAuthClient client = OAuthClient(username: '');
            bool successful = await client.obtainCredentials(
                context: context, prompt: _prompt);
            gmailApi = client.getApi();

            if (successful) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) {
                  return WelcomeScreen(
                    api: gmailApi,
                  );
                }),
              );
            }
          },
          child: const Text('Sign in'),
        ),
      ),
    );
  }
}
