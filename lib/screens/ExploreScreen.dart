import 'package:flutter/material.dart';
import 'package:letter_shelf/screens/popular_categories.dart';
import 'package:letter_shelf/screens/top_25.dart';
import 'package:letter_shelf/widgets/category_card.dart';
import 'package:letter_shelf/widgets/explore_newsletter_card.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Padding
              SizedBox(
                height: 60,
              ),

              // Search Bar
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: SizedBox(
                  height: 60,
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    elevation: 4,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search,
                            size: 30,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            'Search Newsletter',
                            style:
                                TextStyle(fontSize: 18, color: Colors.black45),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Popular Categories
              SizedBox(
                height: 20,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Popular Categories",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => PopularCategories(),
                          )
                        );
                      },
                      icon: Icon(Icons.arrow_forward_ios_sharp),
                    )
                  ],
                ),
              ),

              Container(
                height: MediaQuery.of(context).size.height * 0.16,
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: CategoryCard(text: 'Business', backgroundColor: Colors.redAccent, ),
                    ),
                    Expanded(
                      child: CategoryCard(text: 'Education', backgroundColor: Colors.blue, ),
                    ),
                  ],
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.16,
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: CategoryCard(text: 'Politics', backgroundColor: Colors.green, ),
                    ),
                    Expanded(
                      child: CategoryCard( text: 'Tech', backgroundColor: Colors.amber, ),
                    ),
                  ],
                ),
              ),

              // Top 10
              SizedBox(
                height: 20,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Top 25",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const Top25(),
                          ),
                        );
                      },
                      icon: Icon(Icons.arrow_forward_ios_sharp),
                    )
                  ],
                ),
              ),

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
