import 'package:flutter/material.dart';
import 'package:googleapis/gmail/v1.dart' as gmail;
import 'package:googleapis/people/v1.dart' as people;

abstract class ScreenCheckLoader {
  Future<void> init();
  Future<void> checkForFile( gmail.GmailApi? gmailApi, people.PeopleServiceApi? peopleApi );
  Future<bool> fileExists();
  FutureBuilder buildFutureBuilder();
}