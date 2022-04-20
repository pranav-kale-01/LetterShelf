import 'package:flutter/material.dart';
import 'package:googleapis/gmail/v1.dart' as gmail;
import 'package:letter_shelf/screens/add_custom_newsletter.dart';
import 'package:letter_shelf/screens/manage_newsletters.dart';
import 'package:letter_shelf/screens/requrest_newsletter_addition.dart';

class ManageNewslettersSettings extends StatelessWidget {
  final gmail.GmailApi gmailApi;
  final double bottomPadding;

  const ManageNewslettersSettings({Key? key, required this.gmailApi, required this.bottomPadding}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
        backgroundColor: Colors.white,
        title: const Text(
          'Manage Newsletters',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      body: Column(
        children: [
          // Manage Newsletters List
          Container(
            margin: EdgeInsets.symmetric( horizontal: 7, vertical: 1),
            child: GestureDetector(
              onTap: () {
                // redirecting to user_newsletter_list
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => UserNewsletterList(gmailApi: gmailApi)),
                );
              },
              child: Container(
                height: 60,
                child: Card(
                  elevation: 1,
                  child: Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: FlutterLogo(
                          size: 32,
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.03),
                        child: const Text(
                          "Manage newsletter List",
                          style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w400
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Request Newsletter Addition
          Container(
            margin: EdgeInsets.symmetric( horizontal: 7, vertical: 1),
            child: GestureDetector(
              onTap: () {
                // redirecting to request_newsletter_addition
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => RequestNewsletterAddition( gmailApi: gmailApi,) ),
                );
              },
              child: Container(
                height: 60,
                child: Card(
                  elevation: 1,
                  child: Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: FlutterLogo(
                          size: 32,
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.03),
                        child: const Text(
                          "Request Newsletter Addition",
                          style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w400
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Add Custom Newsletter
          Container(
            margin: EdgeInsets.symmetric( horizontal: 7, vertical: 1),
            child: GestureDetector(
              onTap: () {
                // redirecting to user_newsletter_list
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => AddCustomNewsletter( gmailApi: gmailApi,) ),
                );
              },
              child: Container(
                height: 60,
                child: Card(
                  elevation: 1,
                  child: Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: FlutterLogo(
                          size: 32,
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.03),
                        child: const Text(
                          "Add Custom newsletter",
                          style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w400
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
