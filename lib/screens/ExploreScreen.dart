import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:letter_shelf/screens/popular_categories.dart';
import 'package:letter_shelf/screens/top_25.dart';
import 'package:letter_shelf/utils/explore_screen_carousel_tile.dart';
import 'package:letter_shelf/widgets/browse_categories_tile.dart';
import 'package:letter_shelf/widgets/category_card.dart';
import 'package:letter_shelf/widgets/top_newsletter_card.dart';

class ExploreScreen extends StatelessWidget {
  List<Widget> carouselItems = [];

  ExploreScreen({Key? key}) : super(key: key) {
    carouselItems = [
      ExploreScreenCarouselTile(
        title: "Catch up with the World",
        image: Image.network(
          "https://images.unsplash.com/photo-1521295121783-8a321d551ad2?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8MXx8d29ybGQlMjBuZXdzfGVufDB8fDB8fA%3D%3D&w=1000&q=80",
          fit: BoxFit.fitWidth,
        ),
      ),
      ExploreScreenCarouselTile(
        title: "For Tech Geeks",
        image: Image.network(
          "https://images.unsplash.com/photo-1518770660439-4636190af475?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8M3x8dGVjaG5vbG9neXxlbnwwfHwwfHw%3D&w=1000&q=80",
          fit: BoxFit.fitWidth,
        ),
      ),
      ExploreScreenCarouselTile(
        title: "Best Picks for Food Lovers",
        image: Image.network(
          "https://cdn.tasteatlas.com//images/toplistarticles/d0e6a0a79d5f4197a51f4ca065393ffe.jpg?w=375&h=280",
          fit: BoxFit.fitWidth,
        ),
      ),
      ExploreScreenCarouselTile(
        title: "Straight from the Wall St.",
        image: Image.network(
          "https://images.indianexpress.com/2021/04/wall-street-1200.jpg",
          fit: BoxFit.fitWidth,
        ),
      ),
    ];
  }

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
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
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
                  items: carouselItems,
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
                        image: Image.network(
                            "https://assets.entrepreneur.com/content/3x2/2000/20191127190639-shutterstock-431848417-crop.jpeg",
                            fit: BoxFit.fitWidth,
                        ),
                      ),
                    ),
                    Expanded(
                      child: CategoryCard(
                        text: 'Lifestyle', 
                        image: Image.network(
                            "https://headerpop.com/wp-content/uploads/2019/08/lifestyle-scaled.jpg",
                            fit: BoxFit.fitWidth,
                        ),
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
                        image: Image.network(
                            "https://media.istockphoto.com/photos/political-fund-raising-for-congress-running-for-reelection-washington-picture-id1296606378?b=1&k=20&m=1296606378&s=170667a&w=0&h=SXs2feEbDzpW4_Mx0lIMwo6AvAlVga2ApTPu9koiano=",
                            fit: BoxFit.fitWidth,
                        ),
                      ),
                    ),
                    Expanded(
                      child: CategoryCard(
                        text: 'Tech',
                        image: Image.network(
                            "https://bahriatech.com/wp-content/uploads/2021/10/businessman-using-tech-devices-icons-thin-line-interface_117023-904-1.jpg",
                            fit: BoxFit.fitWidth,
                        ),
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

              Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.symmetric(horizontal: 12.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      TopNewsletterCard(newsletterData: {'id': 'Morning Brew', 'organization': 'Morning Brew'}, cardHeight: 190, cardWidth: 150,),
                      TopNewsletterCard(newsletterData: {'id': 'Medium Daily Digest', 'organization': 'Medium'}, cardHeight: 190, cardWidth: 150,),
                      TopNewsletterCard(newsletterData: {'id': 'Emerging Tech Brew', 'organization': 'Morning Brew'}, cardHeight: 190, cardWidth: 150,),
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
}
