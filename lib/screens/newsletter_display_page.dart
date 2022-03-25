import 'package:flutter/material.dart';

class NewsletterDisplayPage extends StatefulWidget {
  const NewsletterDisplayPage({Key? key}) : super(key: key);

  @override
  _NewsletterDisplayPageState createState() => _NewsletterDisplayPageState();
}

class _NewsletterDisplayPageState extends State<NewsletterDisplayPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(251, 251, 251, 1),
        elevation: 0,
        iconTheme: IconThemeData(
            color: Colors.black
        ),
        title: Text(
          "Top 25",
          style: TextStyle(
              color: Colors.black
          ),
        ),
      ),
      body: SafeArea(
          child: Container(
            alignment: Alignment.center,
            child: Text('test'),
          )
      ),
    );
  }
}
