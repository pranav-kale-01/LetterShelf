import 'dart:io';
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:letter_shelf/screens/HomeScreen.dart';
import 'package:letter_shelf/screens/SetupScreen.dart';
import 'package:letter_shelf/screens/sign_in_screen.dart';

import 'package:letter_shelf/utils/google_auth_client.dart';
import 'package:letter_shelf/utils/google_user.dart';
import 'package:letter_shelf/utils/Utils.dart';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/gmail/v1.dart' as gmail;
import 'package:googleapis/people/v1.dart' as people;

class CredentialCheckLoader extends StatefulWidget {
  GoogleSignInAccount? currentUser;
  late gmail.GmailApi? gmailApi;
  late people.PeopleServiceApi? peopleApi;

  CredentialCheckLoader({
    Key? key,
    this.currentUser,
    this.gmailApi,
    this.peopleApi
  }) : super(key: key);

  @override
  _CredentialCheckLoaderState createState() => _CredentialCheckLoaderState();
}

class _CredentialCheckLoaderState extends State<CredentialCheckLoader> with SingleTickerProviderStateMixin {
  late Widget redirectedScreen;
  late Future<void> userPresent;

  gmail.GmailApi? gmailApi;
  people.PeopleServiceApi? peopleApi;

  // for animating loading icon
  late AnimationController spinAnimationController;
  late Animation spinAnimation;
  MediaQueryData? mediaQuery;
  bool gotResults = false;

  GoogleSignInAccount? user;

  @override
  void initState() {
    super.initState();

    spinAnimationController = AnimationController(
      vsync: this,
      duration: const Duration( milliseconds: 1200 ),
    );

    spinAnimation = Tween<double>(begin: 0.0, end: 1.0, )
        .chain(CurveTween( curve: Curves.linearToEaseOut) )
        .animate(spinAnimationController)
      ..addListener(() {
        setState( () {});
      });

    spinAnimationController.repeat();

    // calling the asynchronous function to decide redirecting screen
    checkResultStatus();
  }

  Future<void> checkResultStatus() async {
    Timer.periodic(
        const Duration( milliseconds: 1100 ),
        (timer) async {
          // checking if results are fetched
          if( gotResults ) {
            // navigating to the selected redirect screen
            Navigator.of(context).pushReplacement(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => redirectedScreen,
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
            );
            timer.cancel();
          }
        }
    );
  }

  Future<void> setRedirectScreen( ) async {
    user = widget.currentUser ?? await ensureLoggedInOnStartUp();

    if( user == null ) {
      redirectedScreen = SignInScreen(
        mediaQuery: mediaQuery!,
      );
    }
    else {
      // checking for newsletter list ( newsletter list check loader )
      try {
        final authHeaders = await user!.authHeaders;
        final authenticatedClient = GoogleAuthClient( authHeaders );
        final bool exists = await fileExists(user!);

        gmailApi = gmail.GmailApi(authenticatedClient);
        peopleApi = people.PeopleServiceApi( authenticatedClient );

        // redirectedScreen = exists ? HomeScreen(
        redirectedScreen = exists ? HomeScreen(
            user: user!,
            gmailApi: gmailApi!,
            peopleApi: peopleApi!
        ) : SetupScreen(
            user: user!,
            gmailApi: gmailApi!,
            peopleApi: peopleApi!
        );
      }
      catch (e, stacktrace) {
        debugPrint(e.toString());
        debugPrint(stacktrace.toString());

        redirectedScreen = SignInScreen(
          mediaQuery: mediaQuery!,
        );

        gotResults = true;
      }
    }

    gotResults = true;
  }

  Future<bool> fileExists(GoogleSignInAccount user) async {
    final directory = await Utils.localPath;
    List<FileSystemEntity> files = directory.listSync();

    RegExp re = RegExp(r'newsletterslist_' + user.email + '.json');
    bool fileExists = false;

    for (FileSystemEntity ent in files) {
      if (re.hasMatch(ent.toString())) {
        fileExists = true;
      }
    }

    return fileExists;
  }

  @override
  Widget build(BuildContext context) {
    mediaQuery ??= MediaQuery.of(context);

    setRedirectScreen();

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Container(
            //   width: 5,
            //   height: mediaQuery.size.height,
            //   color: Colors.blue,
            //   margin: EdgeInsets.only(left: (mediaQuery.size.width * 0.5)- 2.5 ),
            // ),
            // Container(
            //   width: mediaQuery.size.width,
            //   height: 5,
            //   color: Colors.blue,
            //   margin: EdgeInsets.only(top: (mediaQuery.size.height * 0.5)- 2.5 ),
            // ),
            Transform.translate(
              offset: Offset(  (mediaQuery!.size.width * 0.5) - 70, ((mediaQuery!.size.height * 0.5) - (mediaQuery!.padding.top + 60 ) ) ),
              child: Transform.rotate(
                angle: 2.0 * math.pi * spinAnimation.value,
                child: SizedBox(
                  height: 150.0,
                  width: 150.0,
                  child: SvgPicture.asset(
                    "assets/svg/letter_shelf_logo_trimmed.svg",
                    color: const Color(0xFFe63e6b),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
      // stopping the animations and removing the listeners
      spinAnimation.removeListener(() { });
      spinAnimationController.stop();
      super.dispose();
    }
}
