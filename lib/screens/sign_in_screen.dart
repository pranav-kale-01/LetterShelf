import 'dart:ui';
import 'dart:math' as math;

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:letter_shelf/screen_loaders/credentialCheckLoader.dart';

import 'package:letter_shelf/utils/google_user.dart';
import 'package:letter_shelf/widgets/sign_in_screen/dashed_path_painter.dart';

class SignInScreen extends StatefulWidget {
  final MediaQueryData mediaQuery;

  const SignInScreen({
    Key? key,
    required this.mediaQuery
  }) : super(key: key);

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> with TickerProviderStateMixin {
  late AnimationController translateAnimationController;
  late AnimationController scaleAnimationController;
  late AnimationController _controller1;
  late AnimationController _controller2;

  late Animation _xAnimation;
  late Animation _yAnimation;
  late Animation _scaleAnimation;
  late Animation _animation1;
  late Animation _animation2;

  Path? _path;
  int _index1 = 0;
  int _index2 = 0;

  Future? waitForInit;

  List<String> imgList = [
    'assets/images/image-1.jpg',
    'assets/images/image-2.png',
    'assets/images/image-3.jpg',
  ];

  // int _current = 0;
  GoogleSignInAccount? user;

  @override
  void initState() {
    super.initState();

    _controller1 = AnimationController(
        vsync: this,duration:
        const Duration(milliseconds: 1000)
    );

    _controller2 = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1000)
    );

    translateAnimationController = AnimationController(
      vsync: this,
      duration: const Duration( milliseconds: 600 ),
    );

    scaleAnimationController = AnimationController(
      vsync: this,
      duration: const Duration( milliseconds: 900 ),
    );

    _xAnimation = Tween<double>(begin: (widget.mediaQuery.size.width * 0.5) - 82, end: 0.0, )
      .chain(CurveTween( curve: Curves.linearToEaseOut) )
      .animate(translateAnimationController)
      ..addListener(() {
        setState( () {});
      });

    _yAnimation = Tween<double>(begin: ((widget.mediaQuery.size.height * 0.5) - (widget.mediaQuery.padding.top + 57 ) ), end: 0.0, )
      .chain(CurveTween( curve: Curves.linearToEaseOut) )
      .animate(translateAnimationController)
      ..addListener(() {
        setState( () {});
      });

    _scaleAnimation = Tween<double>(begin: 150, end: 50, )
      .chain(CurveTween( curve: Curves.linearToEaseOut) )
      .animate(scaleAnimationController)
      ..addListener(() {
        setState( () {});
      });

    _animation1 = Tween(begin: 0.0,end: 1.0).animate(_controller1)
      ..addListener((){
        setState(() {
        });
      });

    _animation2 = Tween(begin: 0.0,end: 1.0).animate(_controller2)
      ..addListener((){
        setState(() {
        });
      });

    // firing the animation functions
    changePositions();
    foo1();

    Future.delayed(
      const Duration( milliseconds: 1000 ),
      () {
        foo2();
    });
  }

  void foo1() {
    _controller1.forward().whenComplete(() {
      _index1 = _index1 < 3 ? _index1+1 : 0;
      _controller1.reset();
      foo1();
    });
  }

  void foo2() {
    _controller2.forward().whenComplete(() {
      _index2 = _index2 < 3 ? _index2+1 : 0;
      _controller2.reset();
      foo2();
    });
  }


  Path drawPath( mediaQuery ) {
    Size size = Size(mediaQuery.size.width,mediaQuery.size.height);
    Path path = Path();
    path.moveTo(0, size.height / 2);
    path.addArc(Rect.fromLTRB(size.width * 0.35, size.height*0.73, size.width*1.5, size.height*1.1), math.pi, (math.pi*0.39) );
    path.addArc(Rect.fromLTRB(size.width * 0.1, size.height*0.43, size.width*1.1, size.height*0.746), (math.pi/2) - (math.pi*0.08) , -math.pi );
    path.addArc(Rect.fromLTRB( -80, size.height*0.02, size.width*0.85, size.height*0.442), (math.pi*0.416), (math.pi*1.043) );
    path.addArc(Rect.fromLTRB( size.width * 0.05, size.height*0.021, size.width*0.45, size.height*0.05), (math.pi * 1.52), math.pi*1.3 );
    path.lineTo( 0, (size.height * 0.02));
    return path;
  }

  Offset calculate(value, count ) {
    PathMetrics pathMetrics = _path!.computeMetrics();
    PathMetric pathMetric = pathMetrics.elementAt( count == 1 ? _index1 : _index2 );
    value = pathMetric.length * value;
    Tangent? pos = pathMetric.getTangentForOffset(value);
    return pos!.position;
  }

  Future<void> changePositions() async {
    translateAnimationController.forward();
    scaleAnimationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    _path ??= drawPath(MediaQuery.of(context) );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // painting the path
            Positioned(
              top: 0,
              child: CustomPaint(
                painter: DashedPathPainter(originalPath: _path!, pathColor: Colors.black26, strokeWidth: 2, dashLength: 6, dashGapLength: 5),
              ),
            ),

            // first mail
            Positioned(
              top: calculate(_animation1.value, 1).dy - 15,
              left: calculate(_animation1.value, 1).dx,
              child: SizedBox(
                width: 30,
                height: 30,
                child: Image.network(
                  'https://external-content.duckduckgo.com/iu/?u=http%3A%2F%2Fwww.newdesignfile.com%2Fpostpic%2F2011%2F12%2Femail-icon-transparent_230759.png&f=1&nofb=1&ipt=842ad383f9ad0db3e33265e85d751087b8adbd593606986770d12528487b01be&ipo=images'
                ),
              ),
            ),

            // second mail
            Positioned(
              top: calculate(_animation2.value, 2).dy - 15,
              left: calculate(_animation2.value, 2).dx,
              child: SizedBox(
                width: 30,
                height: 30,
                child: Image.network(
                    'https://external-content.duckduckgo.com/iu/?u=http%3A%2F%2Fwww.newdesignfile.com%2Fpostpic%2F2011%2F12%2Femail-icon-transparent_230759.png&f=1&nofb=1&ipt=842ad383f9ad0db3e33265e85d751087b8adbd593606986770d12528487b01be&ipo=images'
                ),
              ),
            ),

            Transform.translate(
              offset: Offset( _xAnimation.value, _yAnimation.value ),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only( left: 12.0, top: 13.0, ),
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: _scaleAnimation.value,
                          height: _scaleAnimation.value,
                          child: Hero(
                            tag: 'main_logo',
                            child: SvgPicture.asset(
                              'assets/svg/letter_shelf_logo_trimmed.svg',
                              color: const Color(0xFFe63e6b),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(top: 10, left: 16),
                    width: MediaQuery.of(context).size.width,
                    child: Text(
                        'Welcome To LetterShelf!',
                        style: TextStyle(
                            fontSize: _scaleAnimation.value - 26,
                            height: 1,
                            fontWeight: FontWeight.w700,
                            overflow: TextOverflow.ellipsis
                          ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(top: 8, left: 16),
                    width: MediaQuery.of(context).size.width,
                    child: const Text(
                      'Simplify, Streamline, and save Time!',
                      style: TextStyle(
                        fontWeight: FontWeight.w300
                      ),
                    ),
                  ),
                  Expanded(
                    child: CarouselSlider(
                      options: CarouselOptions(
                        onPageChanged: (index, _ ) {
                          setState(() {
                            // _current = index;
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
                            SizedBox(
                              width: MediaQuery.of(context).size.width ,
                              height: 300,
                              child: const Image(
                                height: 400,
                                width: 400,
                                image: AssetImage(
                                    'assets/images/image-1.jpg'
                                ),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric( horizontal: 12.0, ),
                              child: const Text(
                                'A better way of reading newsletters',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600
                                ),
                                textAlign: TextAlign.center,
                              ),
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
                                    'assets/images/image-2.png'
                                ),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric( horizontal: 12.0, ),
                              child: const Text(
                                'Explore and find new & interesting newsletters',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600
                                ),
                                textAlign: TextAlign.center,
                              ),
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
                              'Be more focused and Creative with your time',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600
                              ),
                              textAlign: TextAlign.center,
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: imgList.map((image) {
                  //     int index= imgList.indexOf(image);
                  //     return Container(
                  //       height: 8.0,
                  //       margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 2.0),
                  //       decoration: BoxDecoration(
                  //           // shape: BoxShape.circle,
                  //           borderRadius: BorderRadius.circular(50),
                  //           color: _current == index
                  //               ? const Color.fromRGBO(0, 0, 0, 0.4)
                  //               : const Color.fromRGBO(0, 0, 0, 0.2)
                  //       ),
                  //       child: SizedBox(
                  //         width: _current == index ? 16 : 8 ,
                  //       ),
                  //     );
                  //   },
                  //   ).toList(),
                  // ),
                  Container(
                    margin: const EdgeInsets.only(top: 20),
                    height: 90,
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.symmetric( vertical: 18.0,horizontal: 16.0),
                    child: ElevatedButton(
                      style: ButtonStyle(
                        elevation: MaterialStateProperty.all(5),
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        backgroundColor: MaterialStateProperty.all<Color>( Colors.white ),
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
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) {
                              return CredentialCheckLoader(
                                currentUser: user,
                              );
                            }),
                          );
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0, ),
                            child: Image.network(
                              'https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fwww.shareicon.net%2Fdata%2F2016%2F07%2F10%2F119930_google_512x512.png&f=1&nofb=1&ipt=d2729d869d1eadf7b0af8cf7d4f422b91ec27f94ea68a88d4b837604c43cc016&ipo=images'
                            ),
                          ),
                          const Text(
                            'Sign in With Google',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}