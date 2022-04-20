import 'package:flutter/material.dart';
import 'package:letter_shelf/widgets/top_newsletter_tile.dart';

class Top25 extends StatelessWidget {
  const Top25({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(251, 251, 251, 1),
        elevation: 0,
        iconTheme: IconThemeData(
          color: Colors.black
        ),
        title: Text(
            "Top 25",
            style: TextStyle(
              color: Colors.black
            ),
        ),
      ),
      body: Container(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                TopNewsletterTile(newsletterData: {'id' : 'Eater Austin', 'organization' : 'Eater'}),
                TopNewsletterTile(newsletterData: {'id' : 'Emerging Tech Brew', 'organization' : 'Morning Brew'}),
                TopNewsletterTile(newsletterData: {'id' : 'Medium Daily Digest', 'organization' : 'Medium'}),
                TopNewsletterTile(newsletterData: {'id' : 'Morning Brew', 'organization' : 'Morning Brew'}),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
