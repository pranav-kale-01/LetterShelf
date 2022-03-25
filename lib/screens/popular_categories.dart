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
          alignment: Alignment.center,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.16,
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: CategoryCard(text: 'Business', backgroundColor: Colors.limeAccent, ),
                      ),
                      Expanded(
                        child: CategoryCard(text: 'Education', backgroundColor: Colors.grey, textColor: Colors.black ),
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
                        child: CategoryCard(text: 'Business', backgroundColor: Colors.greenAccent, ),
                      ),
                      Expanded(
                        child: CategoryCard(text: 'Education', backgroundColor: Colors.purpleAccent, ),
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
                        child: CategoryCard(text: 'Business', backgroundColor: Colors.blueAccent, ),
                      ),
                      Expanded(
                        child: CategoryCard(text: 'Education', backgroundColor: Colors.deepOrangeAccent, ),
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
                        child: CategoryCard(text: 'Business', backgroundColor: Colors.greenAccent, ),
                      ),
                      Expanded(
                        child: CategoryCard(text: 'Education', backgroundColor: Colors.purpleAccent, ),
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
                        child: CategoryCard(text: 'Business', backgroundColor: Colors.blueAccent, ),
                      ),
                      Expanded(
                        child: CategoryCard(text: 'Education', backgroundColor: Colors.deepOrangeAccent, ),
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
                        child: CategoryCard(text: 'Business', backgroundColor: Colors.greenAccent, ),
                      ),
                      Expanded(
                        child: CategoryCard(text: 'Education', backgroundColor: Colors.purpleAccent, ),
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
                        child: CategoryCard(text: 'Business', backgroundColor: Colors.blueAccent, ),
                      ),
                      Expanded(
                        child: CategoryCard(text: 'Education', backgroundColor: Colors.deepOrangeAccent, ),
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
                        child: CategoryCard(text: 'Business', backgroundColor: Colors.greenAccent, ),
                      ),
                      Expanded(
                        child: CategoryCard(text: 'Education', backgroundColor: Colors.purpleAccent, ),
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
