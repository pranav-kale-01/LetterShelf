import 'package:flutter/material.dart';

import '../widgets/explore_newsletter_card.dart';

class CategorizedList extends StatefulWidget {
  final String keyword;

  const CategorizedList({Key? key, required this.keyword}) : super(key: key);

  @override
  _CategorizedListState createState() => _CategorizedListState();
}

class _CategorizedListState extends State<CategorizedList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(251, 251, 251, 1),
        elevation: 0,
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        title: Text(
          widget.keyword,
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              ExploreNewsletterCard(title: 'Morning Brew', description: 'The daily email newsletter covering the latest news from Wall St. to Silicon Valley.' ),
              ExploreNewsletterCard(title: 'Pocket', description: 'The daily email newsletter covering the latest news from Wall St. to Silicon Valley.' ),
              ExploreNewsletterCard(title: 'Medium Daily Digest', description: 'The daily email newsletter covering the latest news from Wall St. to Silicon Valley.' ),
              ExploreNewsletterCard(title: 'Emerging Tech Brew', description: 'The daily email newsletter covering the latest news from Wall St. to Silicon Valley.' ),
            ],
          ),
        ),
      ),
    );
  }
}
