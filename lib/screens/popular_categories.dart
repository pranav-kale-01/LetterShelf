import 'package:flutter/material.dart';

import '../widgets/category_card.dart';

class PopularCategories extends StatefulWidget {
  const PopularCategories({Key? key}) : super(key: key);

  @override
  _PopularCategoriesState createState() => _PopularCategoriesState();
}

class _PopularCategoriesState extends State<PopularCategories> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(251, 251, 251, 1),
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.black
        ),
        title: Text(
            "Popular Categories",
            style: TextStyle(
              color: Colors.black,
            ),
        ),
      ),
      body: SafeArea(
        child: Container(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.16,
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: CategoryCard(
                          text: 'Business',
                          backgroundColor: Colors.red,
                        ),
                      ),
                      Expanded(
                        child: CategoryCard(
                            text: 'Lifestyle',
                            backgroundColor: Colors.blue,
                        ),
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
                        child: CategoryCard(
                          text: 'Politics',
                          backgroundColor: Colors.green,
                        ),
                      ),
                      Expanded(
                        child: CategoryCard(
                          text: 'Tech',
                          backgroundColor: Colors.amber,
                          textColor: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
