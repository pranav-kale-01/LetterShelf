import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:letter_shelf/screens/SignInScreen.dart';
import 'package:letter_shelf/screens/preferences_screen.dart';
import 'package:letter_shelf/utils/google_user.dart';
import 'package:letter_shelf/widgets/profile_screen/profile_card.dart';

import 'package:googleapis/gmail/v1.dart' as gmail;
import 'package:googleapis/people/v1.dart' as people;

import 'manage_newsletters_settings.dart';

class ProfileScreen extends StatelessWidget {
  final double bottomPadding;
  final gmail.GmailApi gmailApi;
  final people.PeopleServiceApi peopleApi;
  final GoogleSignInAccount user;


  const ProfileScreen({Key? key, required this.user, required this.bottomPadding, required this.gmailApi, required this.peopleApi}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.black87
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
              Padding(
                padding: const EdgeInsets.only(top: 15.0),
                child: ProfileCard( user: user, bottomPadding: bottomPadding),
              ),

              // Manage newsletters
              Container(
                margin: const EdgeInsets.symmetric( horizontal: 7, vertical: 1),
                child: GestureDetector(
                  onTap: () {
                    // redirecting to manage_newsletters_settings screen
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => ManageNewslettersSettings( gmailApi: gmailApi, bottomPadding: bottomPadding),
                      ),
                    );

                  },
                  child: SizedBox(
                    height: 70,
                    child: Card(
                      elevation: 1,
                      child: Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 15, top: 2),
                            child: Icon(
                              Icons.mail_outline_rounded,
                              size: 28,
                            )
                          ),
                          Container(
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.03),
                            child: const Text(
                              "Manage newsletters",
                              style: TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.w400
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Preferences
              Container(
                margin: const EdgeInsets.symmetric( horizontal: 7, vertical: 1),
                child: GestureDetector(
                  onTap: () {
                    // redirecting to manage newsletters list screen
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const PreferredScreen() )
                    );
                  },
                  child: SizedBox(
                    height: 70,
                    child: Card(
                      elevation: 1,
                      child: Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 15, top: 2),
                            child: Icon(
                              Icons.settings_outlined,
                              size: 28,
                            )
                          ),
                          Container(
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.03),
                            child: const Text(
                              "Preferences",
                              style: TextStyle(
                                  fontSize: 21,
                                  fontWeight: FontWeight.w400
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Support us
              // Container(
              //   margin: EdgeInsets.symmetric( horizontal: 7, vertical: 3),
              //   child: GestureDetector(
              //     onTap: () {
              //
              //       // redirecting to manage newsletters list screen
              //
              //     },
              //     child: SizedBox(
              //       height: 60,
              //       child: Card(
              //         elevation: 1,
              //         child: Row(
              //           children: [
              //             Padding(
              //               padding: EdgeInsets.symmetric(horizontal: 8),
              //               child: FlutterLogo(
              //                 size: 32,
              //               ),
              //             ),
              //             Container(
              //               alignment: Alignment.centerLeft,
              //               padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.03),
              //               child: const Text(
              //                 "Support Us",
              //                 style: TextStyle(
              //                     fontSize: 19,
              //                     fontWeight: FontWeight.w400
              //                 ),
              //               ),
              //             ),
              //           ],
              //         ),
              //       ),
              //     ),
              //   ),
              // ),

              // Log Out
              Container(
                margin: const EdgeInsets.symmetric( horizontal: 7, vertical: 1),
                child: GestureDetector(
                  onTap: () async {
                    // logging out the user
                    bool result = await signOutGoogle();

                    if( result ) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const SignInScreen(),
                        ),
                      );
                    }
                  },
                  child: SizedBox(
                    height: 70,
                    child: Card(
                      elevation: 1,
                      child: Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 15, top: 2, right: 2),
                            child: Icon(
                              Icons.login_outlined,
                              color: Colors.red,
                              size: 28,
                            )
                          ),
                          Container(
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.03),
                            child: const Text(
                              "Log Out",
                              style: TextStyle(
                                  fontSize: 21,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.red,
                              ),
                            ),
                          ),
                        ],
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
