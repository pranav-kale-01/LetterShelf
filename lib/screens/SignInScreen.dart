import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/gmail/v1.dart' as gmail;
import 'package:googleapis/people/v1.dart' as people;
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:letter_shelf/utils/OAuthClient.dart';
import 'package:url_launcher/url_launcher.dart';

import 'SetupScreen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  late gmail.GmailApi gmailApi;
  late people.PeopleServiceApi peopleApi;
  late http.Client client;
  List<String> imgList = [
    'assets/images/image-1.jpg',
    'assets/images/image-2.jpg',
    'assets/images/image-3.jpg',
  ];

  int _current = 0;

  // prompt for user to sign-in using the consent Screen
  void _prompt(String url, BuildContext ctx) {
    showDialog(
      context: ctx,
      builder: (BuildContext context) {
        return Dialog(
          child: GestureDetector(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only( top: 16.0, bottom: 24),
                    child: Text(
                      "Google Sign In",
                      style: TextStyle(
                        fontSize: 26,
                      ),
                    ),
                  ),
                  Text(
                    'Please go the following URL to Sign in with your Google Account',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Container(
                    height: 2,
                    color: Colors.black12,
                  ),
                  GestureDetector(
                    onTap: () async {
                      launch(url);
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      padding: EdgeInsets.only(right: 8.0,top: 12),
                      alignment: Alignment.center,
                      child: Text(
                        'Open Link',
                        style: TextStyle(
                            color: Colors.blue,
                            fontSize: 22,
                            fontWeight: FontWeight.w500
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only( top: 8.0),
                      child: Image(
                        image: AssetImage(
                            'assets/images/letter_shelf_logo_trimmed.png'),
                        width: 50,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 20, left: 8),
                width: MediaQuery.of(context).size.width,
                child: Text(
                    'Welcome To LetterShelf..',
                    style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w700
                    ),
                ),
              ),
              // Container(
              //   padding: EdgeInsets.only(left: 8, top: 10, right: 30),
              //   width: MediaQuery.of(context).size.width,
              //   child: Text(
              //       "Your one stop shop for a newsletter reader",
              //       textAlign: TextAlign.left,
              //       style: TextStyle(
              //         fontSize: 18,
              //         fontWeight: FontWeight.w400
              //       ),
              //   ),
              // ),

              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: CarouselSlider(
                    options: CarouselOptions(
                      onPageChanged: (index, _ ) {
                        setState(() {
                          _current = index;
                          debugPrint(_current.toString());
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
                            padding: EdgeInsets.all(10),
                            child: Image(
                              height: 400,
                              width: 400,
                              image: AssetImage(
                                  'assets/images/image-1.jpg'
                              ),
                            ),
                          ),
                          Text(''
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
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: 300,
                            child: Image(
                              height: 250,
                              width: 250,
                              image: AssetImage(
                                  'assets/images/image-2.jpg'
                              ),
                            ),
                          ),
                          Text(
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
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: 300,
                            child: Image(
                              height: 250,
                              width: 250,
                              image: AssetImage(
                                  'assets/images/image-3.jpg'
                              ),
                            ),
                          ),
                          Text(
                            'Explore and find new & intresting newsletters',
                            style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w600
                            ),
                            textAlign: TextAlign.center,
                          )
                        ],
                      ),
                      // Container(
                      //   width: MediaQuery.of(context).size.width,
                      //   height: 300,
                      //   child: Image(
                      //     height: 250,
                      //     width: 250,
                      //     image: AssetImage(
                      //         'assets/images/image-4.jpg'
                      //     ),
                      //   ),
                      // ),
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
                    margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 2.0),
                    decoration: BoxDecoration(
                        // shape: BoxShape.circle,
                        borderRadius: BorderRadius.circular(50),
                        color: _current == index
                            ? Color.fromRGBO(0, 0, 0, 0.4)
                            : Color.fromRGBO(0, 0, 0, 0.2)
                    ),
                    child: SizedBox(
                      width: _current == index ? 16 : 8 ,
                    ),
                  );
                },
                ).toList(),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black12,
                        Colors.white60,
                        Colors.white70,
                        Colors.white,
                      ]
                  ),
                ),
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
                    OAuthClient client = OAuthClient(username: '');

                    bool successful = await client.obtainCredentials( context: context, prompt: _prompt);

                    if (successful) {
                      // getting the AutoRefreshingAuthClient
                      AutoRefreshingAuthClient _authClient = await client.getClient();

                      gmailApi = client.getGmailApi( _authClient );
                      peopleApi = client.getPeopleApi( _authClient );

                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) {
                          return SetupScreen( gmailApi: gmailApi, peopleApi: peopleApi );
                        }),
                      );
                    }
                  },
                  child: const Text(
                    'Sign in With Google',
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
      // floatingActionButton: Container(
      //   decoration: BoxDecoration(
      //     gradient: LinearGradient(
      //         begin: Alignment.topCenter,
      //         end: Alignment.bottomCenter,
      //         colors: [
      //           Colors.transparent,
      //           Colors.black12,
      //           Colors.white60,
      //           Colors.white70,
      //           Colors.white,
      //         ]
      //     ),
      //   ),
      //   height: 90,
      //   width: MediaQuery.of(context).size.width,
      //   padding: const EdgeInsets.symmetric( vertical: 18.0,horizontal: 12.0),
      //   child: ElevatedButton(
      //     style: ButtonStyle(
      //       shape: MaterialStateProperty.all<RoundedRectangleBorder>(
      //         RoundedRectangleBorder(
      //           borderRadius: BorderRadius.circular(16),
      //         ),
      //       ),
      //       backgroundColor: MaterialStateProperty.all<Color>( const Color.fromRGBO(230, 62, 107, 1), ),
      //     ),
      //     onPressed: () async {
      //       OAuthClient client = OAuthClient(username: '');
      //
      //       bool successful = await client.obtainCredentials( context: context, prompt: _prompt);
      //
      //       if (successful) {
      //         // getting the AutoRefreshingAuthClient
      //         AutoRefreshingAuthClient _authClient = await client.getClient();
      //
      //         gmailApi = client.getGmailApi( _authClient );
      //         peopleApi = client.getPeopleApi( _authClient );
      //
      //         Navigator.of(context).pushReplacement(
      //           MaterialPageRoute(builder: (context) {
      //             return SetupScreen( gmailApi: gmailApi, peopleApi: peopleApi );
      //           }),
      //         );
      //       }
      //     },
      //     child: const Text(
      //       'Sign in With Google',
      //       style: TextStyle(
      //         fontSize: 22,
      //         color: Colors.white,
      //       ),
      //     ),
      //   ),
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
