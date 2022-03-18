import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:googleapis/gmail/v1.dart' as gmail;
import 'Utils.dart';

class CreateLoggedinUser {
  final gmail.GmailApi api;

  CreateLoggedinUser({required this.api}){
    init();
  }

  Future<String> getCurrentUserName() async {
    gmail.Profile userProfile = await api.users.getProfile('me');
    return userProfile.emailAddress!;
  }

  Future<void> init() async {
    try {
      // creating a file for the current logged in user
      final currentUser = await getCurrentUserName();
      final localPath = (await Utils.localPath).path;

      File currentUserFile = File(localPath + '/currentUser.json');
      await currentUserFile.create();

      Map<String, dynamic> json = {
        'user': currentUser
      };

      currentUserFile.writeAsString(jsonEncode(json));
    }
    catch (exe) {
      if (kDebugMode) {
        print( exe.toString() );
      }
    }
  }
}