import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:letter_shelf/screen_loaders/newsletterslistCheckLoader.dart';
import 'package:letter_shelf/utils/google_user.dart';
import 'package:letter_shelf/screens/SignInScreen.dart';

class CredentialCheckLoader extends StatefulWidget {
  const CredentialCheckLoader({Key? key}) : super(key: key);

  @override
  _CredentialCheckLoaderState createState() => _CredentialCheckLoaderState();
}

class _CredentialCheckLoaderState extends State<CredentialCheckLoader> {
  late Widget redirectedScreen;
  late Future<void> userPresent;

  GoogleSignInAccount? user;

  @override
  void initState() {
    super.initState();
    userPresent = init();
  }

  @override
  Future<void> init() async {
    user = await ensureLoggedInOnStartUp();
    redirectedScreen = user != null ? NewsletterListCheckLoader(user: user!) : const SignInScreen();
  }

  @override
  FutureBuilder buildFutureBuilder() {
    return FutureBuilder(
        future: userPresent,
        builder: (context, snapshot) {
          if( snapshot.connectionState == ConnectionState.done ){
            return redirectedScreen;
          }
          else if( snapshot.hasError ){
            return Scaffold(
              backgroundColor: Colors.white,
              body: Container(
                alignment: Alignment.center,
                child: Text( snapshot.error.toString() ),
              ),
            );
          }
          else {
            return Scaffold(
              body: Container(
                alignment: Alignment.center,
                child: const CircularProgressIndicator(),
              ),
            );
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return buildFutureBuilder();
  }
}
