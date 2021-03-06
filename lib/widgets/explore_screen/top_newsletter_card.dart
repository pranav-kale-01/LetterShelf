import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:letter_shelf/firebase_operations/storage_service.dart';
import 'package:letter_shelf/screens/newsletter_display_page.dart';
import 'package:letter_shelf/utils/Utils.dart';

import 'package:http/http.dart' as http;
import 'package:letter_shelf/utils/hive_services.dart';

class TopNewsletterCard extends StatefulWidget {
  final bool enabledCaching;
  final double cardWidth;
  final double cardHeight;
  final Map<String, dynamic> newsletterData;

  const TopNewsletterCard({Key? key, required this.newsletterData, required this.cardWidth, required this.cardHeight, required this.enabledCaching}) : super(key: key);

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

    bool loadFromCache = true;

    if( !Utils.firstScreenLoad( widget.newsletterData['id'] + "CachedImage" ) ) {
      // if it's that the image is being loaded since the start of the app, we will load the image from api
      loadFromCache = false;
    }

    if( loadFromCache && widget.enabledCaching ) {
      try {
        Utils.firstInboxScreenLoad = false;
        List<dynamic> tempList = await hiveService.getBoxes( widget.newsletterData['id'] + "CachedImage" );
        Uint8List rawImage = Uint8List.fromList( List<int>.from( tempList ) );
        image = Image.memory( rawImage) ;
        setState(() {

        });
      }
      catch( e, stackTrace ) {
        debugPrint( e.toString() );
        debugPrint( stackTrace.toString());
        image = null;
        setState(() {

        });
      }
    }
    else {
        try {
          // getting logo
          List<String> fileNames = await storage.listLogosFile( widget.newsletterData['id'] );

          if( fileNames.isNotEmpty ) {
            String url = await storage.getDownloadUrl(fileNames[0]);

            if( widget.enabledCaching ) {
              http.Response response = await http.get(Uri.parse(url));
              Box _box = await Hive.openBox( widget.newsletterData['id'] + "CachedImage");
              _box.deleteAll(_box.keys);

              await hiveService.addBoxes(response.bodyBytes, widget.newsletterData['id'] + "CachedImage");
              Utils.firstScreenLoad(widget.newsletterData['id'] + "CachedImage", true);
            }

            setState(() => image = Image.network(
              url,
              fit: BoxFit.fitWidth,
            ));
          }
        }
        catch( e, stackTrace ) {
          debugPrint( e.toString() );
          debugPrint( stackTrace.toString() );
          image = null;
          setState(() {

          });
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
                style: const TextStyle(
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
                style: const TextStyle(
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
