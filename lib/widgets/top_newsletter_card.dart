import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:letter_shelf/screens/newsletter_display_page.dart';

import '../utils/Utils.dart';

class TopNewsletterCard extends StatelessWidget {
  final Map<String, dynamic> newsletterData;

  const TopNewsletterCard({Key? key, required this.newsletterData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        // getting newsletter Data from Firebase
        try {
          FirebaseFirestore db = FirebaseFirestore.instance;

          CollectionReference newslettersReference = db.collection("newsletters_list");

          DocumentSnapshot _docSnapshot = await newslettersReference.doc( newsletterData['id'] ).get();
          Map<String, dynamic> _querySnapshot = _docSnapshot.data() as Map<String,dynamic>;

          _querySnapshot.addAll( { "id" : newsletterData['id'] } );

          debugPrint( _querySnapshot.toString() );

          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => NewsletterDisplayPage(newsletterData: _querySnapshot))
          );
        }
        catch( e, stacktrace ) {
          debugPrint( e.toString() );
          debugPrint( stacktrace.toString() );

        }

      },
      child: Container(
        height: 160,
        width: 150,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Card(
                elevation: 2,
                child: Container(
                  alignment: Alignment.center,
                  child: Text( Utils.getInitials( newsletterData['id'] ) ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6.0),
              child: Text(
                  newsletterData['id'],
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
                  newsletterData['organization'],
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
