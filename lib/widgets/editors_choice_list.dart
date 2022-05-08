import 'dart:ui';

import 'package:flutter/material.dart';
import '../widgets/top_newsletter_card.dart';

class EditorsChoiceList extends StatefulWidget {
  final String titleString;
  final String imageUrl;
  final List<dynamic> featuredNewsletters;

  const EditorsChoiceList({Key? key, required this.titleString, required this.imageUrl, required this.featuredNewsletters}) : super(key: key);

  @override
  _EditorsChoiceListState createState() => _EditorsChoiceListState();
}

class _EditorsChoiceListState extends State<EditorsChoiceList> {
  late ScrollController scrollController;
  late Image image;
  List<Widget> featuredNewslettersCards = [];

  @override
  void initState() {
    super.initState();

    image = Image.network(
        widget.imageUrl,
        fit: BoxFit.fitWidth,
    );
  }

  void addFeaturedNewslettersCard(double screenWidth) {
    featuredNewslettersCards.addAll([
      Container(
        width: MediaQuery.of(context).size.width,
        height: 150,
        color: Colors.transparent,
      ),
      Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          color: Colors.white,
        ),
        height: 20,
      ),
    ]);

    for( int count = 0; count < widget.featuredNewsletters.length; count+=2 ) {
      featuredNewslettersCards.add(
        Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TopNewsletterCard(
                  newsletterData: widget.featuredNewsletters[count],
                  cardHeight: (screenWidth / 2 ) + 50,
                  cardWidth: (screenWidth / 2 ) - 10,
                  enabledCaching: false,
              ),
              count + 1 < widget.featuredNewsletters.length ? TopNewsletterCard(
                newsletterData: widget.featuredNewsletters[count+1],
                cardHeight: (screenWidth / 2 ) + 50,
                cardWidth: ( screenWidth / 2 ) - 10,
                enabledCaching: false,
              ) : Expanded(
                child: Container(),
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width - 15;
    addFeaturedNewslettersCard(screenWidth);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(251, 251, 251, 1),
        elevation: 0,
        iconTheme: IconThemeData(
            color: Colors.black
        ),
        title: Text(
          "",
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
          child: Stack(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: 170,
                child: Stack(
                  children: [
                    Container(
                        width: MediaQuery.of(context).size.width,
                        child: image,
                    ),
                    Container(
                      color: Colors.black26,
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      alignment: Alignment.center,
                      child: Text(
                        widget.titleString,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              SingleChildScrollView(
                child: Column(
                  children: featuredNewslettersCards,
                ),
                // child: Column(
                //   children: [
                //     Container(
                //       color: Colors.white,
                //       child: Row(
                //         mainAxisAlignment: MainAxisAlignment.center,
                //         children: [
                //           TopNewsletterCard(newsletterData: {'id' : 'Eater Austin', 'organization' : 'Eater'}, cardHeight: (screenWidth / 2 ) + 50, cardWidth: screenWidth / 2,),
                //           TopNewsletterCard(newsletterData: {'id' : 'Emerging Tech Brew', 'organization' : 'Morning Brew'}, cardHeight: (screenWidth / 2 ) + 50, cardWidth: screenWidth / 2,),
                //         ],
                //       ),
                //     ),
                //     Container(
                //       color: Colors.white,
                //       child: Row(
                //         mainAxisAlignment: MainAxisAlignment.center,
                //         children: [
                //           TopNewsletterCard(newsletterData: {'id' : 'Medium Daily Digest', 'organization' : 'Medium'}, cardHeight: (screenWidth / 2 ) + 50, cardWidth: screenWidth / 2,),
                //           TopNewsletterCard(newsletterData: {'id' : 'Morning Brew', 'organization' : 'Morning Brew'}, cardHeight: (screenWidth / 2 ) + 50, cardWidth: screenWidth / 2,),
                //         ],
                //       ),
                //     ),
                //     Container(
                //       color: Colors.white,
                //       child: Row(
                //         mainAxisAlignment: MainAxisAlignment.center,
                //         children: [
                //           TopNewsletterCard(newsletterData: {'id' : 'Bits', 'organization' : 'The New York Times'}, cardHeight: (screenWidth / 2 ) + 50, cardWidth: screenWidth / 2,),
                //           TopNewsletterCard(newsletterData: {'id' : 'CNN News Alert', 'organization' : 'CNN'}, cardHeight: (screenWidth / 2 ) + 50, cardWidth: screenWidth / 2,),
                //         ],
                //       ),
                //     ),
                //     Container(
                //       color: Colors.white,
                //       child: Row(
                //         mainAxisAlignment: MainAxisAlignment.center,
                //         children: [
                //           TopNewsletterCard(newsletterData: {'id' : 'Cooking', 'organization' : 'The New York Times'}, cardHeight: (screenWidth / 2 ) + 50, cardWidth: screenWidth / 2,),
                //           TopNewsletterCard(newsletterData: {'id' : 'Dharma Markets Report', 'organization' : 'Dharma Labs'}, cardHeight: (screenWidth / 2 ) + 50, cardWidth: screenWidth / 2,),
                //         ],
                //       ),
                //     ),
                //     Container(
                //       color: Colors.white,
                //       child: Row(
                //         mainAxisAlignment: MainAxisAlignment.center,
                //         children: [
                //           TopNewsletterCard(newsletterData: {'id' : 'Morning Briefing', 'organization' : 'The New York Times'}, cardHeight: (screenWidth / 2 ) + 50, cardWidth: screenWidth / 2,),
                //           TopNewsletterCard(newsletterData: {'id' : 'Running', 'organization' : 'The New York Times'}, cardHeight: (screenWidth / 2 ) + 50, cardWidth: screenWidth / 2,),
                //         ],
                //       ),
                //     ),
                //   ],
                // ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
