import 'package:flutter/material.dart';
import 'package:googleapis/gmail/v1.dart' as gmail;
import 'package:letter_shelf/models/emailMessage.dart';
import 'package:letter_shelf/utils/Utils.dart';

import 'package:hive/hive.dart';
import 'package:letter_shelf/utils/hive_services.dart';

import 'HomeScreenListTile.dart';

class SavedScreenList extends StatefulWidget {
  SavedScreenList({ Key? key, }) : super(key: key);

  @override
  _SavedScreenListState createState() => _SavedScreenListState();
}

class _SavedScreenListState extends State<SavedScreenList> {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Text('Downloaded messages here'),
    );
  }
}
