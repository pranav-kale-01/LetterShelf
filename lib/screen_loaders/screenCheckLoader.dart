import 'package:flutter/material.dart';
import 'package:googleapis/gmail/v1.dart' as gmail;

abstract class ScreenCheckLoader {
  Future<void> init();
  Future<void> checkForFile( gmail.GmailApi? api );
  Future<bool> fileExists();
  FutureBuilder buildFutureBuilder();
}