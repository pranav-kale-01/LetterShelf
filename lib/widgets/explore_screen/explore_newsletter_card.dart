import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:letter_shelf/screens/newsletter_display_page.dart';
import 'package:letter_shelf/utils/hive_services.dart';

import '../../firebase_operations/storage_service.dart';
import '../../utils/Utils.dart';

class ExploreNewsletterCard extends StatefulWidget {
  final Map<String, dynamic> newsletterData;

  const ExploreNewsletterCard({Key? key, required this.newsletterData})
      : super(key: key);

  @override
  _ExploreNewsletterCardState createState() => _ExploreNewsletterCardState();
}

class _ExploreNewsletterCardState extends State<ExploreNewsletterCard> {
  HiveServices hiveService = HiveServices();
  Storage storage = Storage();
  Image? image;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    bool exists = await hiveService.isExists( boxName: widget.newsletterData['id'] + "CachedImage");
    if (exists) {

      Utils.firstInboxScreenLoad = false;
      List<dynamic> tempList = await hiveService
          .getBoxes(widget.newsletterData['id'] + "CachedImage");
      Uint8List rawImage = Uint8List.fromList(List<int>.from(tempList));
      image = Image.memory(
        rawImage,
        fit: BoxFit.fitWidth,
      );
      setState(() {});

    } else {
      Future.delayed(const Duration(seconds: 1), () async {
          List<String> fileNames = await storage.listLogosFile(widget.newsletterData['id']);
          if ( fileNames.isNotEmpty ) {
            String url = await storage.getDownloadUrl(fileNames[0]);
            http.Response response = await http.get(Uri.parse(url));

            Box _box = await Hive.openBox(widget.newsletterData['id'] + "CachedImage");
            _box.deleteAll(_box.keys);

            await hiveService.addBoxes(response.bodyBytes, widget.newsletterData['id'] + "CachedImage");
            setState(
              () => image = Image.network(
                url,
                fit: BoxFit.fitWidth,
              ),
            );
          }

          setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
              builder: (context) => NewsletterDisplayPage(
                    newsletterData: widget.newsletterData,
                  )),
        );
      },
      child: Container(
        height: 130,
        padding: EdgeInsets.symmetric(horizontal: 2),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Organization Image
                Padding(
                  padding:
                      const EdgeInsets.only(top: 10.0, right: 10, left: 10),
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50)),
                    elevation: 1,
                    child: CircleAvatar(
                      radius: 36,
                      backgroundColor: Color.fromRGBO(238, 26, 81, 0.7),
                      child: image == null
                          ? Text(
                              Utils.getInitials(
                                widget.newsletterData['id'],
                              ),
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600),
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: image,
                            ),
                    ),
                  ),
                ),

                // Organization Details
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 3.0),
                          child: Text(
                            widget.newsletterData['id'],
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          widget.newsletterData['description'],
                          overflow: TextOverflow.ellipsis,
                          maxLines: 3,
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // More Details
                Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 14.0),
                  child: const Icon(
                    Icons.arrow_forward_ios_sharp,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
