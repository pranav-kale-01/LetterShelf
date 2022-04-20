import 'package:flutter/material.dart';
import 'package:letter_shelf/widgets/add_new_newsletters_list_tile.dart';
import 'package:googleapis/gmail/v1.dart' as gmail;

import '../models/subscribed_newsletters.dart';

class AddNewNewslettersList extends StatefulWidget {
  final gmail.GmailApi gmailApi;
  final List jsonData; 
  
  const AddNewNewslettersList({Key? key,required this.gmailApi, required this.jsonData}) : super(key: key);

  @override
  _AddNewNewslettersListState createState() => _AddNewNewslettersListState();
}

class _AddNewNewslettersListState extends State<AddNewNewslettersList> {
  @override
  Widget build(BuildContext context) {
    return  Container(
      alignment: Alignment.center,
      child: ListView.builder(itemBuilder: (context, index) {
        // creating new object of SubscribedNewsletter
        SubscribedNewsletter letter = SubscribedNewsletter(
          name: widget.jsonData[index]['name'],
          email: widget.jsonData[index]['email'],
          enabled: false,
        );

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
          child: AddNewNewslettersListTile(gmailApi: widget.gmailApi, newsletter: letter),
        );
      },
        itemCount: widget.jsonData.length ,
      ),
    );
  }
}
