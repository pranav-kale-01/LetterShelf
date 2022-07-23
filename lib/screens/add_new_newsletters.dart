import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:letter_shelf/widgets/profile_screen/add_new_newsletters_list.dart';
import 'package:googleapis/gmail/v1.dart' as gmail;
import '../firebase_operations/firebase_utils.dart';

class AddNewNewsletters extends StatefulWidget {
  final gmail.GmailApi gmailApi;

  const AddNewNewsletters({Key? key, required this.gmailApi}) : super(key: key);

  @override
  _AddNewNewslettersState createState() => _AddNewNewslettersState();
}

class _AddNewNewslettersState extends State<AddNewNewsletters> {
  late Future<void> loadingCompleted;
  List< Map<String, String> > jsonList = [];

  @override
  void initState() {
    super.initState();

    loadingCompleted = init();
  }

  Future<void> init() async {
      // getting all newsletter accounts present in database
      // creating a reference of firebase db
      FirebaseFirestore db = FirebaseFirestore.instance;

      // showing the list of available newsletter emails
      FirebaseUtils utils = FirebaseUtils( db: db );
      List<dynamic> data = await utils.getData( );

      for (var i in data) {
        Map<String, dynamic> decodedData = jsonDecode(i);

        jsonList.add({
          "name": decodedData['newsletter_name'],
          "email": decodedData['email'],
        });
      }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
        backgroundColor: Colors.white,
        title: const Text(
          'Manage Newsletters',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      body: FutureBuilder(
        future: loadingCompleted,
        builder: (context, snapshot ) {
          if( snapshot.connectionState == ConnectionState.done ) {
            return AddNewNewslettersList( gmailApi: widget.gmailApi, jsonData: jsonList );
          }
          else if( snapshot.hasError ) {
            return Container(
              alignment: Alignment.center,
              child: Text( snapshot.error.toString() ),
            );
          }
          else {
            return Container(
              alignment: Alignment.center,
              child: const CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
