import 'package:flutter/material.dart';

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
                      padding: EdgeInsets.symmetric(horizontal: 20),
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
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Popular Category",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.arrow_forward_ios_sharp),
                    )
                  ],
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.16,
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Business',
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Education',
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.16,
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.greenAccent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Politics',
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors.black,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.amberAccent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Tech',
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors.black,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Top 10
              SizedBox(
                height: 20,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
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
                      onPressed: () {},
                      icon: Icon(Icons.arrow_forward_ios_sharp),
                    )
                  ],
                ),
              ),

              Container(
                height: 90,
                padding: EdgeInsets.symmetric(horizontal: 20),
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
                          child: Text("MB"),
                        ),
                      ),

                      // Organization Details
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                'Morning Brew',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                ),
                            ),
                            Text(
                                'The daily email newsletter covering the latest news from Wall St. to Silicon Valley.',
                                overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      // More Details
                      IconButton(
                          onPressed: () {},
                          icon: Icon(
                              Icons.arrow_forward_ios_sharp,

                          ),
                      ),
                    ],
                  ),
                ),
              ),

              Container(
                height: 90,
                padding: EdgeInsets.symmetric(horizontal: 20),
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
                          backgroundColor: Colors.deepOrange,
                          child: Text("P"),
                        ),
                      ),

                      // Organization Details
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pocket',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'The daily email newsletter covering the latest news from Wall St. to Silicon Valley.',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      // More Details
                      IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.arrow_forward_ios_sharp,

                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Container(
                height: 90,
                padding: EdgeInsets.symmetric(horizontal: 20),
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
                          backgroundColor: Colors.cyan,
                          child: Text("MD"),
                        ),
                      ),

                      // Organization Details
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Medium Daily Digest',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'The daily email newsletter covering the latest news from Wall St. to Silicon Valley.',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      // More Details
                      IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.arrow_forward_ios_sharp,

                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Container(
                height: 90,
                padding: EdgeInsets.symmetric(horizontal: 20),
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
                          backgroundColor: Colors.amberAccent,
                          child: Text("ET"),
                        ),
                      ),

                      // Organization Details
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Emerging Tech Brew',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'The daily email newsletter covering the latest news from Wall St. to Silicon Valley.',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      // More Details
                      IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.arrow_forward_ios_sharp,

                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
