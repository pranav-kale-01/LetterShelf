import 'package:flutter/material.dart';

class SavedScreenList extends StatefulWidget {
  const SavedScreenList({ Key? key, }) : super(key: key);

  @override
  _SavedScreenListState createState() => _SavedScreenListState();
}

class _SavedScreenListState extends State<SavedScreenList> {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: const Text('Downloaded messages here'),
    );
  }
}
