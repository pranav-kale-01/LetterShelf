import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseUtils {
  final FirebaseFirestore db;
  bool addDataCalled = false;
  bool showDataCalled = false;

  FirebaseUtils( {required this.db });

  Future<void> addData( Map<String, String> data ) async {
    if( addDataCalled ) {
      return;
    }
    addDataCalled = true;

    try {
      FirebaseFirestore db = FirebaseFirestore.instance;

      await db.collection("newsletters_list").doc(data['email']).set(data);
    }
    catch( e ) {
      print(e);
    }

    addDataCalled = false;
  }

  Future<void> showData( ) async {
    if( showDataCalled ){
      return;
    }
    showDataCalled = true;

    try {
      QuerySnapshot data = await db.collection("newsletters_list").get();

      // getting all the docs from the document
      List<QueryDocumentSnapshot> docs = data.docs;

      // looping over the list of docs
      for( var i in docs ) {
        print( i.get('name') );
        print( i.get('email') );
        print( i.get('organization') );
      }
    }
    catch( e ) {
      print( e );
    }
    showDataCalled = false;
  }

  Future<List<dynamic>> getData( { GetOptions? options}) async {
    List<dynamic> _data = [];

    try {
      QuerySnapshot data;

      if( options == null ) {
        data = await db.collection("newsletters_list").get();
      }
      else {
        data = await db.collection("newsletters_list").get( options );
      }

      // looping over the list of docs
      for( var i in data.docs ) {
        // creating a new Map
        Map<String, String> temp = {};

        // adding required information to the Map
        temp.addAll({'newsletter_name': i.id, 'email': i.get('email')});

        // adding the Map to the list of Maps
        _data.add( jsonEncode(temp) );
      }
    }
    catch( e ) {
      print( "firebase_utils" + e.toString() );
    }

    return _data;
  }
}