import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/gmail/v1.dart' as gmail;
import 'package:googleapis/people/v1.dart' as people;

import 'Utils.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

// if present, creates a reference to the credentials file stored in the documents directory
Future<File> _credentialsFile( String username) async {
  final path = (await Utils.localPath).path;
  return File('$path/credentials_' + username + '.json');
}

final GoogleSignIn googleSignIn = GoogleSignIn.standard(
    scopes: [
      gmail.GmailApi.gmailModifyScope,
      gmail.GmailApi.gmailReadonlyScope,
      people.PeopleServiceApi.contactsOtherReadonlyScope,
    ]);

Future<GoogleSignInAccount?> ensureLoggedInOnStartUp() async {
  // That class has a currentUser if there's already a user signed in on
  // this device.
  try {
    GoogleSignInAccount? googleSignInAccount = googleSignIn.currentUser;
    if (googleSignInAccount == null) {
      // but if not, Google should try to sign one in who's previously signed in
      // on this phone.
      googleSignInAccount = await googleSignIn.signInSilently();
      if (googleSignInAccount == null) return null;

      final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      final UserCredential authResult = await _auth.signInWithCredential(credential);
      final User? user = authResult.user;

      final User? currentUser = _auth.currentUser;
      assert(user!.uid == currentUser?.uid);

      return googleSignInAccount;
    }
  }  catch (e, stacktrace) { //on PlatformException
    debugPrint(e.toString());
    debugPrint(stacktrace.toString());
  }
  return null;
}

Future<GoogleSignInAccount?> signInWithGoogle() async {
  try {
    final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();

    if( googleSignInAccount != null ) {
      final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      // throws FirebaseException when no internet connection
      final UserCredential authResult = await _auth.signInWithCredential(credential);
      final User? user = authResult.user;

      final User? currentUser = _auth.currentUser;
      assert(user?.uid == currentUser!.uid);

      return googleSignInAccount;
    }
  }
  catch (e,s) {
    debugPrint(e.toString());
    debugPrint(s.toString());

    return null;
  }

  return null;
}

Future<bool> signOutGoogle() async {
  if(googleSignIn.currentUser != null ) {
    await googleSignIn.signOut();
    await FirebaseAuth.instance.signOut();
    return true;
  }

  return false;
}