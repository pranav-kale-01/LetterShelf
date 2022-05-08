import 'package:flutter/material.dart';

import '../widgets/top_newsletter_card.dart';

class Top25 extends StatelessWidget {
  const Top25({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width - 15;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(251, 251, 251, 1),
        elevation: 0,
        iconTheme: IconThemeData(
          color: Colors.black
        ),
        title: Text(
            "Top 10",
            style: TextStyle(
              color: Colors.black
            ),
        ),
      ),
      body: Container(
        color: Color.fromRGBO(247, 247, 247, 1),
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TopNewsletterCard(newsletterData: {'id' : 'Eater Austin', 'organization' : 'Eater'}, cardHeight: (screenWidth / 2 ) + 50, cardWidth: screenWidth / 2, enabledCaching: false,),
                    TopNewsletterCard(newsletterData: {'id' : 'Emerging Tech Brew', 'organization' : 'Morning Brew'}, cardHeight: (screenWidth / 2 ) + 50, cardWidth: screenWidth / 2, enabledCaching: false,),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TopNewsletterCard(newsletterData: {'id' : 'Medium Daily Digest', 'organization' : 'Medium'}, cardHeight: (screenWidth / 2 ) + 50, cardWidth: screenWidth / 2, enabledCaching: false,),
                    TopNewsletterCard(newsletterData: {'id' : 'Morning Brew', 'organization' : 'Morning Brew'}, cardHeight: (screenWidth / 2 ) + 50, cardWidth: screenWidth / 2, enabledCaching: false,),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TopNewsletterCard(newsletterData: {'id' : 'Bits', 'organization' : 'The New York Times'}, cardHeight: (screenWidth / 2 ) + 50, cardWidth: screenWidth / 2, enabledCaching: false,),
                    TopNewsletterCard(newsletterData: {'id' : 'CNN News Alert', 'organization' : 'CNN'}, cardHeight: (screenWidth / 2 ) + 50, cardWidth: screenWidth / 2, enabledCaching: false,),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TopNewsletterCard(newsletterData: {'id' : 'Cooking', 'organization' : 'The New York Times'}, cardHeight: (screenWidth / 2 ) + 50, cardWidth: screenWidth / 2, enabledCaching: false,),
                    TopNewsletterCard(newsletterData: {'id' : 'Dharma Markets Report', 'organization' : 'Dharma Labs'}, cardHeight: (screenWidth / 2 ) + 50, cardWidth: screenWidth / 2, enabledCaching: false,),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TopNewsletterCard(newsletterData: {'id' : 'Morning Briefing', 'organization' : 'The New York Times'}, cardHeight: (screenWidth / 2 ) + 50, cardWidth: screenWidth / 2, enabledCaching: false,),
                    TopNewsletterCard(newsletterData: {'id' : 'Running', 'organization' : 'The New York Times'}, cardHeight: (screenWidth / 2 ) + 50, cardWidth: screenWidth / 2, enabledCaching: false,),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
