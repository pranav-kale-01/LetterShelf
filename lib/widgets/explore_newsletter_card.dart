import 'package:flutter/material.dart';
import 'package:letter_shelf/screens/newsletter_display_page.dart';

import '../utils/Utils.dart';

class ExploreNewsletterCard extends StatelessWidget {
  final String title;
  final String description;

  const ExploreNewsletterCard({Key? key, required this.title, required this.description}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => NewsletterDisplayPage() ),
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
                  child: Text( Utils.getInitials(title) ),
                ),
              ),

              // Organization Details
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      description,
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
