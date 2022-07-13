import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:letter_shelf/firebase_operations/firebase_utils.dart';

import '../widgets/explore_newsletter_card.dart';

class CategorizedList extends StatefulWidget {
  final String keyword;

  const CategorizedList({Key? key, required this.keyword}) : super(key: key);

  @override
  _CategorizedListState createState() => _CategorizedListState();
}

class _CategorizedListState extends State<CategorizedList> {
  late List<dynamic> newsletters;
  late Future<void> _future;

  @override
  void initState() {
    super.initState();

    _future = init();
  }

  Future<void> init() async {
    newsletters = await getNewslettersByKeyword();
  }

  Future<List<dynamic>> getNewslettersByKeyword(  ) async {
    List<dynamic> data = [];

    // getting all the newsletter that fall under the invoked category from firebase database
    try {
      FirebaseFirestore db = FirebaseFirestore.instance;

      CollectionReference newslettersRefrence = db.collection("newsletters_list");

      QuerySnapshot snapshot = await newslettersRefrence.where( "category", arrayContains: widget.keyword ).get();

      for( var i in snapshot.docs ) {
        Map<String, dynamic> json = {};

        json.addAll( { "id" : i.id } );
        json.addAll( { "category" : i.get("category")} );
        json.addAll( { "email" : i.get("email")} );
        json.addAll( { "duration" : i.get("duration")} );
        json.addAll( { "description" : i.get("description")} );
        json.addAll( { "organization" : i.get("organization")} );

        data.add(json);
      }
    }
    catch( e, stacktrace ) {
      debugPrint( e.toString() );
      debugPrint( stacktrace.toString() );

    }

    return data;
  }


  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        if( snapshot.connectionState == ConnectionState.done ) {
          if( newsletters.isNotEmpty ) {
            return Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                backgroundColor: Color.fromRGBO(251, 251, 251, 1),
                elevation: 0,
                iconTheme: IconThemeData(
                  color: Colors.black,
                ),
                title: Text(
                  widget.keyword,
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
              ),
              body: SafeArea(
                child: ListView.builder(
                  itemBuilder: (ctx, index) {
                    return ExploreNewsletterCard( newsletterData: newsletters[index], );
                  },
                  itemCount: newsletters.length,
                ),
              ),
            );
          }
          else {
            return Scaffold(
              appBar: AppBar(
                backgroundColor: Color.fromRGBO(251, 251, 251, 1),
                elevation: 0,
                iconTheme: IconThemeData(
                  color: Colors.black,
                ),
                title: Text(
                  widget.keyword,
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
              ),
              body: Container(
                alignment: Alignment.center,
                child: Text(
                    "Sorry! No Newsletter are available for this category :)",
                    style: TextStyle(
                      fontSize: 18
                    ),
                    textAlign: TextAlign.center,
                ),
              ),
            );
          }
        }
        else if( snapshot.hasError ) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Color.fromRGBO(251, 251, 251, 1),
              elevation: 0,
              iconTheme: IconThemeData(
                color: Colors.black,
              ),
              title: Text(
                widget.keyword,
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
            body: SafeArea(
              child: Container(
                alignment: Alignment.center,
                child: Text( snapshot.error.toString() ),
              )
            ),
          );
        }
        else {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Color.fromRGBO(251, 251, 251, 1),
              elevation: 0,
              iconTheme: const IconThemeData(
                color: Colors.black,
              ),
              title: Text(
                widget.keyword,
                style: const TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
            body: SafeArea(
              child: Container(
                alignment: Alignment.center,
                  child: const CircularProgressIndicator()
              ),
            ),
          );
        }
      },
    );
  }
}
