import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:letter_shelf/screen_loaders/credentialCheckLoader.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp( const MyApp() );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: CredentialCheckLoader(),
    );
  }
}