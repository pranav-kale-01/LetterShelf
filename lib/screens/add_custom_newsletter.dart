import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import '../utils/OAuthClient.dart';
import '../utils/Utils.dart';

import 'package:googleapis/gmail/v1.dart' as gmail;

class AddCustomNewsletter extends StatelessWidget {
  final gmail.GmailApi gmailApi;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  AddCustomNewsletter({Key? key, required this.gmailApi}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      elevation: 0,
      iconTheme: const IconThemeData(
        color: Colors.black,
      ),
      backgroundColor: Colors.white,
      title: const Text(
        'Add Custom Newsletter',
        style: TextStyle(
          color: Colors.black,
        ),
      ),
    );


    return Scaffold(
      appBar: appBar,
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    left: 16.0, right: 16, top: 12.0, bottom: 22.0),
                child: Text(
                  "Unable to Find a newsletter in our list? No worry, add your own custom newsletter.!",
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.black87,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12.0),
                padding:
                    const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
                child: TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    label: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text('Name'),
                    ),
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12.0),
                padding:
                    const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
                child: TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    label: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text('Email'),
                    ),
                    border: OutlineInputBorder(
                        borderSide: const BorderSide(),
                        borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
                alignment: Alignment.bottomCenter,
                child: ElevatedButton(
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                  onPressed: () async {
                      // replacing the contents of newsletter with the updated file
                      String path = (await Utils.localPath).path;

                      final String username = await OAuthClient.getCurrentUserNameFromApi( gmailApi );

                      // opening user's newsletters list file
                      File file = File( '$path/newsletterslist_' + username + '.json');

                      List<dynamic> jsonData = jsonDecode( file.readAsStringSync() );

                      bool flag = true;
                      for( var i in jsonData ){
                        if( i['name'] == nameController.text && i['email'] == emailController.text ) {
                          flag = false;
                          break;
                        }
                      }

                      if( flag ) {
                        jsonData.add({
                          "name": nameController.text,
                          "email": emailController.text,
                          "enabled": true,
                        });

                        file.writeAsString( jsonEncode( jsonData ) );
                      }

                      Navigator.of(context).pop();
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.symmetric(vertical: 14.0,),
                    child: Text(
                        "Add Newsletter",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.w300,
                        ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
