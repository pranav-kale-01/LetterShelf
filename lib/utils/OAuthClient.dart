import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show BuildContext;
import 'package:googleapis/gmail/v1.dart' as gmail;
import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis/people/v1.dart' as people;
import 'package:http/http.dart' as http;

import 'Utils.dart';

class OAuthClient {
  String username;
  gmail.GmailApi? _gmailApi;
  people.PeopleServiceApi? _peopleServiceApi;
  late http.Client _client;

  OAuthClient({required this.username});

  // creates and returns a AutoRefreshingAutClient from the credentials stored in the user's local storage
  Future<AutoRefreshingAuthClient> getClient() async {
    return await _obtainCredentialsFromFile();
  }

  // returns the reference to Gmail api
  gmail.GmailApi getGmailApi( AutoRefreshingAuthClient _authClient ) {
    gmail.GmailApi _api;
    if( _gmailApi == null  ){
      _api = gmail.GmailApi( _authClient);
    }
    else {
      _api = _gmailApi!;
    }
    return _api;
  }

  people.PeopleServiceApi getPeopleApi( AutoRefreshingAuthClient _authClient ) {
    people.PeopleServiceApi _api;
    if( _peopleServiceApi == null ) {
      _api = people.PeopleServiceApi( _authClient );
    }
    else {
      _api = _peopleServiceApi!;
    }

    return _api;
  }

  // if present, creates a reference to the credentials file stored in the documents directory
  Future<File> get _credentialsFile async {
    final path = (await Utils.localPath).path;
    return File('$path/credentials_' + username + '.json');
  }

  // returns the current authenticated client's username
  Future<String> getCurrentUserName() async {
    try {
      gmail.Profile userProfile = await _gmailApi!.users.getProfile('me');
      return userProfile.emailAddress!;
    }
    catch( e, stacktrace ) {
      debugPrint( e.toString() );
      debugPrint( stacktrace.toString() );

      return "exception occurred";
    }
  }

  static Future<String> getCurrentUserNameFromApi(gmail.GmailApi api) async {
    gmail.Profile userProfile = await api.users.getProfile('me');
    return userProfile.emailAddress!;
  }

  // obtain credentials by prompting consent screen to the user
  Future<bool> obtainCredentials(
      {required BuildContext context,
      required Function(String, BuildContext) prompt}) async {
    // _client = http.Client();

    try {
      AutoRefreshingAuthClient authClient = await clientViaUserConsent(
        ClientId(
          '566804110461-f8uuc235otkefg47r9qfpnsdna0g5ihq.apps.googleusercontent.com',
          '',
        ),
        [
          gmail.GmailApi.gmailReadonlyScope,
          gmail.GmailApi.gmailModifyScope,
          people.PeopleServiceApi.userinfoProfileScope,
        ],
        (url) => prompt(url, context),
      );

      _gmailApi = gmail.GmailApi(authClient);
      _peopleServiceApi = people.PeopleServiceApi(authClient);

      final path = (await Utils.localPath).path;
      username = await getCurrentUserName();
      File file = File(path + '/credentials_' + username + '.json');
      await file.writeAsString(jsonEncode(authClient.credentials));

      return true;
    } on Exception catch (exception) {
      if (kDebugMode) {
        print(exception.toString());
      }

      return false;
    }
  }

  // obtain authenticated client using credentials stored in user's local device storage
  Future<AutoRefreshingAuthClient> _obtainCredentialsFromFile() async {
    _client = http.Client();

    final file = await _credentialsFile;

    // Reading data from the file
    final contents = await file.readAsString();

    // parsing the data from json to Map
    final body = json.decode(contents);
    final tokenBody = body['accessToken'];

    // getting the expiry date for the token
    DateTime expiry = DateTime.parse(tokenBody['expiry']);

    // creating the object for accessToken
    AccessToken token = AccessToken(
      tokenBody['type'],
      tokenBody['data'],
      expiry,
    );

    // creating new AccessCredentials using the initial credential data
    AccessCredentials creds = AccessCredentials(
      token,
      body['refreshToken'],
      [gmail.GmailApi.gmailReadonlyScope],
    );

    // creating a auto-refreshing client from the fetched access-credentials
    AutoRefreshingAuthClient authClient = autoRefreshingClient(
      ClientId(
          '566804110461-f8uuc235otkefg47r9qfpnsdna0g5ihq.apps.googleusercontent.com',
          ''),
      creds,
      _client,
    );

    return authClient;
  }
}
