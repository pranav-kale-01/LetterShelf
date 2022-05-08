import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:letter_shelf/screens/top_25.dart';
import 'package:letter_shelf/widgets/explore_screen_carousel_tile.dart';
import 'package:letter_shelf/widgets/browse_categories_tile.dart';
import 'package:letter_shelf/widgets/category_card.dart';
import 'package:letter_shelf/widgets/top_newsletter_card.dart';

import '../utils/Utils.dart';

class ExploreScreen extends StatefulWidget {
  List<Widget> carouselItems = [];

  ExploreScreen({Key? key}) : super(key: key) {
    // carouselItems = [
    //   ExploreScreenCarouselTile(
    //     title: "Catch up with the World",
    //     image: Image( image: AssetImage( 'assets/images/letter_shelf_logo.jpg' ) ),
    //     imageUrl: "https://images.unsplash.com/photo-1521295121783-8a321d551ad2?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8MXx8d29ybGQlMjBuZXdzfGVufDB8fDB8fA%3D%3D&w=1000&q=80",
    //     featuredNewslettersList: [
    //       {'id' : 'Emerging Tech Brew', 'organization' : 'Morning Brew'},
    //       {'id' : 'Medium Daily Digest', 'organization' : 'Medium'},
    //       {'id' : 'Bits', 'organization' : 'The New York Times'}
    //     ],
    //   ),
    //   ExploreScreenCarouselTile(
    //     title: "For Tech Geeks",
    //     image: Image( image: AssetImage( 'assets/images/letter_shelf_logo.jpg' ), ),
    //     imageUrl: "https://images.unsplash.com/photo-1518770660439-4636190af475?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8M3x8dGVjaG5vbG9neXxlbnwwfHwwfHw%3D&w=1000&q=80",
    //     featuredNewslettersList: [
    //       {'id' : 'Emerging Tech Brew', 'organization' : 'Morning Brew'},
    //       {'id' : 'Bits', 'organization' : 'The New York Times'}
    //     ],
    //   ),
    //   ExploreScreenCarouselTile(
    //     title: "Best Picks for Food Lovers",
    //     image: Image( image: AssetImage( 'assets/images/letter_shelf_logo.jpg' ) ),
    //     imageUrl: "https://cdn.tasteatlas.com//images/toplistarticles/d0e6a0a79d5f4197a51f4ca065393ffe.jpg?w=375&h=280",
    //     featuredNewslettersList: [
    //       {'id' : 'Cooking', 'organization' : 'The New York Times'},
    //       {'id' : 'Eater Austin', 'organization' : 'Eater'}
    //     ],
    //   ),
    //   ExploreScreenCarouselTile(
    //     title: "Straight from the Wall St.",
    //     image: Image( image: AssetImage( 'assets/images/letter_shelf_logo.jpg' ) ),
    //     imageUrl: "https://images.indianexpress.com/2021/04/wall-street-1200.jpg",
    //     featuredNewslettersList: [
    //       {'id' : 'CNN News Alert', 'organization' : 'CNN'}
    //     ],
    //   ),
    // ];



    carouselItems = [
      ExploreScreenCarouselTile(
        title: "Catch up with the World",
        image: Image.network(
          "https://images.unsplash.com/photo-1521295121783-8a321d551ad2?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8MXx8d29ybGQlMjBuZXdzfGVufDB8fDB8fA%3D%3D&w=1000&q=80",
          fit: BoxFit.fitWidth,
        ),
        imageUrl: "https://images.unsplash.com/photo-1521295121783-8a321d551ad2?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8MXx8d29ybGQlMjBuZXdzfGVufDB8fDB8fA%3D%3D&w=1000&q=80",
        featuredNewslettersList: [
          {'id' : 'Emerging Tech Brew', 'organization' : 'Morning Brew'},
          {'id' : 'Medium Daily Digest', 'organization' : 'Medium'},
          {'id' : 'Bits', 'organization' : 'The New York Times'}
        ],
      ),
      ExploreScreenCarouselTile(
        title: "For Tech Geeks",
        image: Image.network(
          "https://images.unsplash.com/photo-1518770660439-4636190af475?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8M3x8dGVjaG5vbG9neXxlbnwwfHwwfHw%3D&w=1000&q=80",
          fit: BoxFit.fitWidth,
        ),
        imageUrl: "https://images.unsplash.com/photo-1518770660439-4636190af475?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8M3x8dGVjaG5vbG9neXxlbnwwfHwwfHw%3D&w=1000&q=80",
        featuredNewslettersList: [
          {'id' : 'Emerging Tech Brew', 'organization' : 'Morning Brew'},
          {'id' : 'Bits', 'organization' : 'The New York Times'}
        ],
      ),
      ExploreScreenCarouselTile(
        title: "Best Picks for Food Lovers",
        image: Image.network(
          "https://cdn.tasteatlas.com//images/toplistarticles/d0e6a0a79d5f4197a51f4ca065393ffe.jpg?w=375&h=280",
          fit: BoxFit.fitWidth,
        ),
        imageUrl: "https://cdn.tasteatlas.com//images/toplistarticles/d0e6a0a79d5f4197a51f4ca065393ffe.jpg?w=375&h=280",
        featuredNewslettersList: [
          {'id' : 'Cooking', 'organization' : 'The New York Times'},
          {'id' : 'Eater Austin', 'organization' : 'Eater'}
        ],
      ),
      ExploreScreenCarouselTile(
        title: "Straight from the Wall St.",
        image: Image.network(
          "https://images.indianexpress.com/2021/04/wall-street-1200.jpg",
          fit: BoxFit.fitWidth,
        ),
        imageUrl: "https://images.indianexpress.com/2021/04/wall-street-1200.jpg",
        featuredNewslettersList: [
          {'id' : 'CNN News Alert', 'organization' : 'CNN'}
        ],
      ),
    ];
  }

  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
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
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              //   child: SizedBox(
              //     height: 60,
              //     child: Card(
              //       shape: RoundedRectangleBorder(
              //           borderRadius: BorderRadius.circular(20)),
              //       elevation: 4,
              //       child: Padding(
              //         padding: EdgeInsets.symmetric(horizontal: 10),
              //         child: Row(
              //           children: [
              //             Icon(
              //               Icons.search,
              //               size: 30,
              //             ),
              //             SizedBox(
              //               width: 10,
              //             ),
              //             Text(
              //               'Search Newsletter',
              //               style:
              //                   TextStyle(fontSize: 18, color: Colors.black45),
              //             ),
              //           ],
              //         ),
              //       ),
              //     ),
              //   ),
              // ),

              // Editor's Choice Carousel
              Padding(
                padding: EdgeInsets.only(left: 10, right: 10, top: 22, bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Editor's Choice",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 8.0),
                child: CarouselSlider(
                  options: CarouselOptions(
                    height: 170.0,
                    autoPlay: true,
                    enlargeCenterPage: true,
                    viewportFraction: 0.98,
                    autoPlayAnimationDuration: const Duration( seconds: 2),
                    autoPlayCurve: Curves.easeOutExpo,
                  ),
                  items: widget.carouselItems,
                ),
              ),

              // Popular Categories
              SizedBox(
                height: 20,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
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
                  ],
                ),
              ),

              Container(
                height: MediaQuery.of(context).size.height * 0.12,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: CategoryCard(
                        text: 'Business',
                        image: Image( image: AssetImage( 'assets/images/business.jpg' ), fit: BoxFit.fitWidth, ),
                      ),
                    ),
                    Expanded(
                      child: CategoryCard(
                        text: 'Lifestyle',
                        image: Image( image: AssetImage( 'assets/images/lifestyle.jpg' ), fit: BoxFit.fitWidth, ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.12,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: CategoryCard(
                        text: 'Politics',
                        image: Image( image: AssetImage( 'assets/images/politics.jpg' ), fit: BoxFit.fitWidth, ),
                      ),
                    ),
                    Expanded(
                      child: CategoryCard(
                        text: 'Tech',
                        image: Image( image: AssetImage( 'assets/images/tech.jpg' ), fit: BoxFit.fitWidth, ),
                      ),
                    ),
                  ],
                ),
              ),

              // Top 25
              SizedBox(
                height: 20,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Top 10",
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

              Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.symmetric(horizontal: 12.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      TopNewsletterCard(newsletterData: {'id': 'Morning Briefing', 'organization': 'Morning Brew'}, cardHeight: 190, cardWidth: 150, enabledCaching: true,),
                      TopNewsletterCard(newsletterData: {'id': 'Morning Brew', 'organization': 'Morning Brew'}, cardHeight: 190, cardWidth: 150, enabledCaching: true,),
                      TopNewsletterCard(newsletterData: {'id': 'CNN News Alert', 'organization': 'Morning Brew'}, cardHeight: 190, cardWidth: 150, enabledCaching: true,),
                      TopNewsletterCard(newsletterData: {'id': 'Dharma Markets Report', 'organization': 'Morning Brew'}, cardHeight: 190, cardWidth: 150, enabledCaching: true,),
                      TopNewsletterCard(newsletterData: {'id': 'Medium Daily Digest', 'organization': 'Medium'}, cardHeight: 190, cardWidth: 150, enabledCaching: true,),
                    ],
                  ),
                ),
              ),

              SizedBox(
                height: 20,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Browse Categories",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              BrowseCategoriesTile( title: "Business",),
              BrowseCategoriesTile( title: "Culture",),
              BrowseCategoriesTile( title: "Crypto",),
              BrowseCategoriesTile( title: "Design",),
              BrowseCategoriesTile( title: "Education",),
              BrowseCategoriesTile( title: "Food",),
              BrowseCategoriesTile( title: "Finance",),
              BrowseCategoriesTile( title: "News" ),
              BrowseCategoriesTile( title: "Sports" ),
              BrowseCategoriesTile( title: "Tech" ),

            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {

    // setting firstload of Explore Screen to false
    Utils.firstExploreScreenLoad = false;

    super.dispose();
  }
}
