import 'package:flutter/material.dart';
import 'package:letter_shelf/screens/newsletter_display_page.dart';

import '../utils/Utils.dart';

class ExploreNewsletterCard extends StatelessWidget {
  final Map<String, dynamic> newsletterData;

  const ExploreNewsletterCard({Key? key, required this.newsletterData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => NewsletterDisplayPage( newsletterData: newsletterData, ) ),
        );
      },
      child: Container(
        height: 90,
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 2,
          child: Row(
            children: [
              // Organization Image
              Padding(
                padding: const EdgeInsets.symmetric( horizontal: 8.0),
                child: CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.greenAccent,
                  child: Text( Utils.getInitials(newsletterData['id']) ),
                ),
              ),

              // Organization Details
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      newsletterData['id'],
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      newsletterData['description'],
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // More Details
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14.0),
                child: const Icon( Icons.arrow_forward_ios_sharp, ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
