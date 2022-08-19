import 'dart:convert';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/gmail/v1.dart' as gmail;
import 'package:googleapis/people/v1.dart' as people;
import 'package:letter_shelf/screen_loaders/newsletterslistCheckLoader.dart';

import 'package:letter_shelf/utils/google_auth_client.dart';
import 'package:letter_shelf/utils/google_user.dart';

import '../utils/Utils.dart';
import 'SetupScreen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  late gmail.GmailApi gmailApi;
  late people.PeopleServiceApi peopleApi;
  // late http.Client client;

  Future? waitForInit;

  List<String> imgList = [
    'assets/images/image-1.jpg',
    'assets/images/image-2.jpg',
    'assets/images/image-3.jpg',
  ];
  //
  // final GoogleSignIn _googleSignIn = GoogleSignIn.standard(
  //   scopes: <String>[
  //     gmail.GmailApi.gmailModifyScope,
  //     gmail.GmailApi.gmailReadonlyScope,
  //     people.PeopleServiceApi.contactsOtherReadonlyScope,
  //   ],
  // );

  int _current = 0;
  GoogleSignInAccount? user;

  @override
  void initState() {
    super.initState();
    // waitForInit = init();
  }

  // Future<void> _handleSignIn() async {
  //   try {
  //     user = await _googleSignIn.signIn();
  //   } catch (error, stacktrace ) {
  //     debugPrint( error.toString() );
  //     debugPrint( stacktrace.toString() );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Padding(
                      padding: EdgeInsets.only( top: 8.0),
                      child: Image(
                        image: AssetImage( 'assets/images/letter_shelf_logo_trimmed.png'),
                        width: 50,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.only(top: 20, left: 8),
                width: MediaQuery.of(context).size.width,
                child: const Text(
                    'Welcome To LetterShelf..',
                    style: TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.w700
                      ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: CarouselSlider(
                    options: CarouselOptions(
                      onPageChanged: (index, _ ) {
                        setState(() {
                          _current = index;
                        });
                      },
                      autoPlay: true,
                      autoPlayCurve: Curves.easeInOutExpo,
                      aspectRatio: 1/1,
                      viewportFraction: 1,
                    ),
                    items: [
                      Column(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width ,
                            height: 300,
                            padding: const EdgeInsets.all(10),
                            child: const Image(
                              height: 400,
                              width: 400,
                              image: AssetImage(
                                  'assets/images/image-1.jpg'
                              ),
                            ),
                          ),
                          const Text(''
                              'A better way of reading newsletters',
                            style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w600
                            ),
                            textAlign: TextAlign.center,
                          )
                        ],
                      ),
                      Column(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: 300,
                            child: const Image(
                              height: 250,
                              width: 250,
                              image: AssetImage(
                                  'assets/images/image-2.jpg'
                              ),
                            ),
                          ),
                          const Text(
                            'Be more focused and Creative with your time',
                            style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w600
                            ),
                            textAlign: TextAlign.center,
                          )
                        ],
                      ),
                      Column(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: 300,
                            child: const Image(
                              height: 250,
                              width: 250,
                              image: AssetImage(
                                  'assets/images/image-3.jpg'
                              ),
                            ),
                          ),
                          const Text(
                            'Explore and find new & interesting newsletters',
                            style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w600
                            ),
                            textAlign: TextAlign.center,
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: imgList.map((image) {
                  int index= imgList.indexOf(image);
                  return Container(
                    height: 8.0,
                    margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 2.0),
                    decoration: BoxDecoration(
                        // shape: BoxShape.circle,
                        borderRadius: BorderRadius.circular(50),
                        color: _current == index
                            ? const Color.fromRGBO(0, 0, 0, 0.4)
                            : const Color.fromRGBO(0, 0, 0, 0.2)
                    ),
                    child: SizedBox(
                      width: _current == index ? 16 : 8 ,
                    ),
                  );
                },
                ).toList(),
              ),
              Container(
                color: Colors.white,
                height: 90,
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.symmetric( vertical: 18.0,horizontal: 12.0),
                child: ElevatedButton(
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    backgroundColor: MaterialStateProperty.all<Color>( const Color.fromRGBO(230, 62, 107, 1), ),
                  ),
                  onPressed: () async {
                    // await _handleSignIn();
                    try {
                      user = await signInWithGoogle();
                    }
                    catch( e, stacktrace ) {
                      debugPrint( e.toString() );
                      debugPrint( stacktrace.toString() );
                    }

                    // if the signing in process was completed successfully
                    if( user != null )
                    {
                      debugPrint( user.toString() );
                      final authHeaders = await user!.authHeaders;
                      final authenticatedClient =  GoogleAuthClient( authHeaders );

                      gmailApi = gmail.GmailApi(authenticatedClient);
                      peopleApi = people.PeopleServiceApi( authenticatedClient );

                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) {
                          return NewsletterListCheckLoader( user: user!, );
                        }),
                      );
                    }
                  },
                  child: const Text(
                    ' Sign in With Google',
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            ],
          )
        ),
      ),
    );
  }
}