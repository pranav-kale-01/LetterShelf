import 'dart:io';

import 'package:flutter/material.dart';
import 'package:letter_shelf/screens/manage_newsletters.dart';
import 'package:letter_shelf/widgets/profile_card.dart';

import 'package:googleapis/gmail/v1.dart' as gmail;
import 'package:googleapis/people/v1.dart' as people;

import '../utils/Utils.dart';
import 'SelectAccount.dart';

class ProfileScreen extends StatelessWidget {
  final double bottomPadding;
  final gmail.GmailApi gmailApi;
  final people.PeopleServiceApi peopleApi;

  const ProfileScreen({Key? key, required this.bottomPadding, required this.gmailApi, required this.peopleApi}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // User Profile
              ProfileCard( gmailApi: gmailApi, peopleApi: peopleApi, bottomPadding: bottomPadding),

              // Manage newsletters list
              GestureDetector(
                onTap: () {
                  // debugPrint("ProfileScreen - tapped");

                  // redirecting to user_newsletter_list screen
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) => UserNewsletterList( gmailApi: gmailApi,),
                    ),
                  );

                },
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.15 - bottomPadding,
                  child: Card(
                    elevation: 1,
                    child: Container(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.03),
                      child: const Text(
                        "Manage newsletter List",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w400
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Preferences
              GestureDetector(
                onTap: () {
                  // debugPrint("ProfileScreen - tapped");

                  // redirecting to manage newsletters list screen

                },
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.15 - bottomPadding,
                  child: Card(
                    elevation: 1,
                    child: Container(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.03),
                      child: const Text(
                        "Preferences",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w400
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Support us
              GestureDetector(
                onTap: () {
                  // debugPrint("ProfileScreen - tapped");

                  // redirecting to manage newsletters list screen

                },
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.15 - bottomPadding,
                  child: Card(
                    elevation: 1,
                    child: Container(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.03),
                      child: const Text(
                        "Support Us",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w400
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Log Out
              GestureDetector(
                onTap: () async {
                  // logging out the user
                  final path = (await Utils.localPath).path;
                  final file = File(path + '/currentUser.json');
                  file.delete();

                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const SelectAccount(),
                    ),
                  );
                },
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.15 - bottomPadding,
                  child: Card(
                    elevation: 1,
                    child: Container(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.03),
                      child: const Text(
                        "Log Out",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
