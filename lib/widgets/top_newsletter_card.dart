import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:letter_shelf/screens/newsletter_display_page.dart';

import '../firebase_operations/storage_service.dart';
import '../utils/Utils.dart';
import '../utils/hive_services.dart';

import 'package:http/http.dart' as http;

class TopNewsletterCard extends StatefulWidget {
  final double cardWidth;
  final double cardHeight;
  final Map<String, dynamic> newsletterData;

  const TopNewsletterCard({Key? key, required this.newsletterData, required this.cardWidth, required this.cardHeight}) : super(key: key);

  @override
  _TopNewsletterCardState createState() => _TopNewsletterCardState();
}

class _TopNewsletterCardState extends State<TopNewsletterCard> {
  final HiveServices hiveService = HiveServices( );
  Storage storage = Storage();
  Image? image;
  late Map<String, dynamic> _querySnapshot;

  @override
  void initState() {
    super.initState();

    init();
  }

  Future<void> init() async {
    FirebaseFirestore db = FirebaseFirestore.instance;

    CollectionReference newslettersReference = db.collection("newsletters_list");

    DocumentSnapshot _docSnapshot = await newslettersReference.doc( widget.newsletterData['id'] ).get();
    _querySnapshot = _docSnapshot.data() as Map<String,dynamic>;
    _querySnapshot.addAll( { "id" : widget.newsletterData['id'] } );

    bool exists = await hiveService.isExists( boxName: widget.newsletterData['id'] + "CachedImage" );
    if(exists && Utils.firstExploreScreenLoad ) {
      debugPrint('if');

      Utils.firstInboxScreenLoad = false;
      List<dynamic> tempList = await hiveService.getBoxes( widget.newsletterData['id'] + "CachedImage" );
      Uint8List rawImage = Uint8List.fromList( List<int>.from( tempList ) );
      image = Image.memory( rawImage);
      setState(() {

      });
    }
    else {
      Future.delayed(const Duration( seconds: 1), () async {
        // creating a reference of firebase db
        FirebaseFirestore db = FirebaseFirestore.instance;


        // showing the list of available newsletter emails
        DocumentSnapshot snapshot = await db.collection("newsletters_list").doc( widget.newsletterData['id'] ).get();

        if( snapshot.data() != null ) {
          Map<String, dynamic> decodedData = jsonDecode( jsonEncode( snapshot.data() ) );

          // getting logo
          if(decodedData['image'] != null ) {
            List<String> fileNames = await storage.listLogosFile( widget.newsletterData['id']);
            String url = await storage.getDownloadUrl( fileNames[0] );
            http.Response response = await http.get( Uri.parse( url) );

            Box _box = await Hive.openBox( widget.newsletterData['id'] + "CachedImage" );
            _box.deleteAll(_box.keys);

            await hiveService.addBoxes(  response.bodyBytes, widget.newsletterData['id'] + "CachedImage");
            setState(() => image = Image.memory(response.bodyBytes) );
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.cardHeight,
      width: widget.cardWidth,
      child: GestureDetector(
        onTap: () async {
          // getting newsletter Data from Firebase
          try {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => NewsletterDisplayPage(newsletterData: _querySnapshot))
            );
          }
          catch( e, stacktrace ) {
            debugPrint( e.toString() );
            debugPrint( stacktrace.toString() );

          }

        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: widget.cardWidth,
              height: widget.cardHeight - 50,
              child: Card(
                elevation: 2,
                child: image ?? Container(
                  alignment: Alignment.center,
                  child: Text(
                      Utils.getInitials( widget.newsletterData['id'] ) ),
                ) ,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6.0),
              child: Text(
                widget.newsletterData['id'],
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6.0),
              child: Text(
                widget.newsletterData['organization'],
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
