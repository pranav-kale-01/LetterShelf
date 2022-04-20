import 'package:flutter/material.dart';

import '../utils/Utils.dart';

class NewsletterDisplayPage extends StatefulWidget {
  final Map<String, dynamic> newsletterData;

  const NewsletterDisplayPage({Key? key, required this.newsletterData})
      : super(key: key);

  @override
  _NewsletterDisplayPageState createState() => _NewsletterDisplayPageState();
}

class _NewsletterDisplayPageState extends State<NewsletterDisplayPage> {
  List<Widget> categories = [];

  @override
  void initState() {
    super.initState();

    List<dynamic> _tempList = widget.newsletterData['category'];

    int count = 1;
    for (var category in _tempList) {
      categories.add(Container(
        padding: const EdgeInsets.only(right: 6.0),
        child: Text(
          category,
          style: const TextStyle(
            color: Colors.grey,
          ),
        ),
      ));

      // adding a separator
      if (count != _tempList.length) {
        categories.add(Padding(
          padding: const EdgeInsets.only(right: 6.0),
          child: SizedBox(
            height: 10,
            width: 2.0,
            child: Container(
              color: Colors.grey,
            ),
          ),
        ));
      }

      count += 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(251, 251, 251, 1),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          "Top 25",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              widget.newsletterData['id'],
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 20,
                              ),
                            ),
                          ),
                          Text(
                            widget.newsletterData['organization'],
                            style: const TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14.0),
                    child: Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: CircleAvatar(
                        radius: 38,
                        backgroundColor: Colors.white,
                        child: Text(
                          Utils.getInitials(widget.newsletterData['id']),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        foregroundColor: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),

              // categories
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  children: categories,
                ),
              ),

              // description
              Padding(
                padding: const EdgeInsets.symmetric( vertical: 18.0,horizontal: 12.0),
                child: Text(
                  widget.newsletterData['description'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w400
                  ),
                ),
              ),


              // Subscribe on the web
              Container(
                height: MediaQuery.of(context).size.height * 0.11,
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.symmetric( vertical: 18.0,horizontal: 12.0),
                child: Container(
                  child: ElevatedButton(
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                    onPressed: () {},
                    child: const Text(
                        'Subscribe on the web',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                        ),
                    ),
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
