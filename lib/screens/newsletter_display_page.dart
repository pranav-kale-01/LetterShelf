import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:letter_shelf/utils/hive_services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../firebase_operations/storage_service.dart';
import '../utils/Utils.dart';

import 'package:http/http.dart' as http;

class NewsletterDisplayPage extends StatefulWidget {
  final Map<String, dynamic> newsletterData;

  const NewsletterDisplayPage({Key? key, required this.newsletterData})
      : super(key: key);

  @override
  _NewsletterDisplayPageState createState() => _NewsletterDisplayPageState();
}

class _NewsletterDisplayPageState extends State<NewsletterDisplayPage> {
  Storage storage = Storage();
  List<Widget> categories = [];
  List<Image> relatedImages = [];
  HiveServices hiveService = HiveServices();

  Image? image;
  late String url;
  late String email;

  @override
  void initState() {
    super.initState();
    init();

    List<dynamic> _tempList = widget.newsletterData['category'];

    int count = 1;
    for (var category in _tempList) {
      categories.add(Container(
        padding: const EdgeInsets.only(right: 6.0),
        child: Text(
          category,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14
          ),
        ),
      ));

      // adding a separator
      if (count != _tempList.length) {
        categories.add(Padding(
          padding: const EdgeInsets.only(right: 6.0),
          child: SizedBox(
            height: 10,
            width: 2.0,
            child: Container(
              color: Colors.grey,
            ),
          ),
        ));
      }

      count += 1;
    }
  }

  Future<void> init() async {
    bool exists = await hiveService.isExists( boxName: widget.newsletterData['id'] + "CachedImage" );

    // creating a reference of firebase db
    FirebaseFirestore db = FirebaseFirestore.instance;

    // showing the list of available newsletter emails
    DocumentSnapshot snapshot = await db.collection("newsletters_list").doc( widget.newsletterData['id'] ).get();

    if(exists && Utils.firstExploreScreenLoad ) {
      debugPrint('if');

      Utils.firstInboxScreenLoad = false;
      List<dynamic> tempList = await hiveService.getBoxes( widget.newsletterData['id'] + "CachedImage" );
      Uint8List rawImage = Uint8List.fromList( List<int>.from( tempList ) );
      image = Image.memory(
        rawImage,
        fit: BoxFit.fitWidth,
      );
      setState(() {

      });
    }
    else {
      if( snapshot.data() != null ) {
        Map<String, dynamic> decodedData = jsonDecode( jsonEncode( snapshot.data() ) );

        // getting logo
        List<String> fileNames = await storage.listLogosFile( widget.newsletterData['id']);
        if( fileNames.isNotEmpty ) {
          String url = await storage.getDownloadUrl( fileNames[0] );
          http.Response response = await http.get( Uri.parse( url) );

          Box _box = await Hive.openBox( widget.newsletterData['id'] + "CachedImage" );
          _box.deleteAll(_box.keys);

          await hiveService.addBoxes(  response.bodyBytes, widget.newsletterData['id'] + "CachedImage");
          setState(() => image = Image.memory(
              response.bodyBytes,
              fit: BoxFit.scaleDown,
            ),
          );
        }
      }
    }

    // setting website_url
    if( snapshot.data() != null ) {
      Map<String, dynamic> decodedData = jsonDecode( jsonEncode( snapshot.data() ) );
      url = decodedData['website_url'];
      email = decodedData['email'];
    }

    // getting related images
    List<String> fileNames = await storage.listImagesFile( widget.newsletterData['id']);
    for( String i in fileNames ) {
      String url = await storage.getDownloadUrl( i );
      relatedImages.add(
        Image.network( url ),
      );

      setState(() { });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(251, 251, 251, 1),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          "",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0, bottom: 4),
                            child: Text(
                              widget.newsletterData['id'],
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 30,
                              ),
                            ),
                          ),
                          Text(
                            widget.newsletterData['organization'],
                            style: const TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 22,
                              color: Colors.black87,
                            ),
                          ),


                          // categories
                          Padding(
                            padding: const EdgeInsets.only(top: 14),
                            child: Row(
                              children: categories,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                    child: Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        child: image == null ? Text(
                          Utils.getInitials(widget.newsletterData['id']),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w500,
                          ),
                        ) : ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: image,
                        ),
                        foregroundColor: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),

              // About Newsletter
              Padding(
                padding: EdgeInsets.only(left: 12, right: 20, top: 12),
                child: Text(
                  "About",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only( top: 8.0, bottom: 18.0, left: 12.0, right: 16.0),
                child: Text(
                  widget.newsletterData['description'],
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400
                  ),
                ),
              ),

              // Duration
              Padding(
                padding: EdgeInsets.only(left: 12, right: 20, top: 2),
                child: Text(
                  "Duration",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12),
                child: Text(
                  widget.newsletterData['duration'],
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400
                  ),
                ),
              ),

              // images carousel
              Padding(
                padding: EdgeInsets.only(left: 12, right: 20, top: 15, bottom: 10),
                child: Text(
                  "Related Images",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 12),
                padding: EdgeInsets.only(top: 0),
                child: CarouselSlider(
                  options: CarouselOptions(
                    aspectRatio: 3/4,
                    viewportFraction: 0.79,
                    autoPlayAnimationDuration: const Duration( seconds: 2),
                    autoPlayCurve: Curves.easeOutExpo,
                  ),
                  items: relatedImages.isEmpty ?  [
                    Card(
                      elevation: 1,
                      child: Container(
                        width: 300,
                        height: 100,
                        alignment: Alignment.center,
                        color: Color.fromRGBO(168, 168, 168, 1),
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                  ] : relatedImages,
                ),
              ),


              // // Try Now
              // Padding(
              //   padding: EdgeInsets.only(left: 12, right: 20, top: 18, bottom: 4),
              //   child: Row(
              //     children: [
              //       Text(
              //         "Try Now",
              //         style: TextStyle(
              //           fontSize: 22,
              //           fontWeight: FontWeight.w600,
              //         ),
              //       ),
              //       Container(
              //         alignment: Alignment.center,
              //         padding: const EdgeInsets.symmetric(horizontal: 14.0),
              //         child: const Icon( Icons.arrow_forward_ios_sharp, ),
              //       ),
              //     ],
              //   ),
              // ),
              SizedBox(
                height: 90,
              )
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
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
            ),
            onPressed: () async {
              try {
                await launch( url);

                // adding newsletter to json file
                // replacing the contents of newsletter with the updated file
                String path = (await Utils.localPath).path;

                final String username = Utils.username;

                // opening user's newsletters list file
                File file = File( '$path/newsletterslist_' + username + '.json');

                List<dynamic> jsonData = jsonDecode( file.readAsStringSync() );

                bool flag = true;
                for( var i in jsonData ){
                  if( i['name'] == widget.newsletterData['id'] && i['email'] == email ) {
                    flag = false;
                    break;
                  }
                }

                if( flag ) {
                  jsonData.add({
                    "name": widget.newsletterData['id'],
                    "email": email,
                    "enabled": true,
                  });

                  // TODO: show added successfully

                  file.writeAsString( jsonEncode( jsonData ) );
                }
              }
              catch( e, stacktrace ) {
                debugPrint( e.toString() );
                debugPrint( stacktrace.toString());
              }
            },
            child: const Text(
              'Subscribe on the web',
              style: TextStyle(
                fontSize: 18,
                color: Colors.black,
              ),
            ),
          ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
