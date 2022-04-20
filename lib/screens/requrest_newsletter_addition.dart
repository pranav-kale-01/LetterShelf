import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/gmail/v1.dart' as gmail;

class RequestNewsletterAddition extends StatelessWidget {
  final gmail.GmailApi gmailApi;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController organizationWebsiteController = TextEditingController();
  late BoxConstraints size;

  RequestNewsletterAddition({Key? key, required this.gmailApi}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      elevation: 0,
      iconTheme: const IconThemeData(
        color: Colors.black,
      ),
      backgroundColor: Colors.white,
      title: const Text(
        'Request Newsletter Addition',
        style: TextStyle(
          color: Colors.black,
        ),
      ),
    );

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: appBar,
      body: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.bottom - MediaQuery.of(context).padding.top - appBar.preferredSize.height - MediaQuery.of(context).viewInsets.bottom ,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
               Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(
                          left: 16.0, right: 16, top: 12.0, bottom: 22.0,
                        ),
                        child: Text(
                          "Want a newsletter to be added to the newsletters list? Worry not, send a request with the details of the newsletters and we will add it to the list.!",
                          style: TextStyle(
                            fontSize: 18.0,
                            color: Colors.black87,
                          ),
                        ),
                      ),

                      // name
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 12.0),
                        padding:
                        const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
                        child: TextField(
                          controller: nameController,
                          decoration: InputDecoration(
                            label: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10.0),
                              child: Text('Name'),
                            ),
                            border: OutlineInputBorder(
                              borderSide: const BorderSide(),
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ),

                      // email
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 12.0),
                        padding:
                        const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
                        child: TextField(
                          controller: emailController,
                          decoration: InputDecoration(
                            label: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10.0),
                              child: Text('Email'),
                            ),
                            border: OutlineInputBorder(
                                borderSide: const BorderSide(),
                                borderRadius: BorderRadius.circular(20)),
                          ),
                        ),
                      ),

                      // organization site
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 12.0),
                      padding:
                      const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
                      child: TextField(
                        controller: organizationWebsiteController,
                        decoration: InputDecoration(
                          label: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.0),
                            child: Text('Organization website'),
                          ),
                          border: OutlineInputBorder(
                              borderSide: const BorderSide(),
                              borderRadius: BorderRadius.circular(20)),
                        ),
                      ),
                    ),
                  ],
              ),

              Container(
                margin: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
                alignment: Alignment.bottomCenter,
                child: ElevatedButton(
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                  onPressed: () async {
                    // checking if any of the text fields are empty
                    if( nameController.text.length == 0 || emailController.text.length ==0 || organizationWebsiteController.text.length == 0 ) {
                      debugPrint("cannot continue");
                      return;
                    }

                    // adding the requested data to firebase
                    Map<String, dynamic> data = {
                      "id" : nameController.text + emailController.text + organizationWebsiteController.text,
                      "name" : nameController.text,
                      "email" : emailController.text,
                      "organization_website" : organizationWebsiteController.text
                    };

                    FirebaseFirestore db = FirebaseFirestore.instance;
                    db.collection("request_list").add( data );

                    // checking if data was added
                    QuerySnapshot snapshot = await db.collection("request_list").where("id", isEqualTo: nameController.text + emailController.text + organizationWebsiteController.text ).get();

                    if( snapshot.size != 0 ) {
                      Navigator.of(context).pop();
                    }
                    else {
                      for( var i in snapshot.docs ) {
                        debugPrint( i.get("id") );
                      }
                      debugPrint( snapshot.size.toString() );
                    }
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.symmetric(vertical: 14.0,),
                    child: const Text(
                      "Request Newsletter",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w300,
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
