import 'package:flutter/material.dart';


class SelectAcccountListTile extends StatelessWidget {
  final String username;

  const SelectAcccountListTile({Key? key, required this.username}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListTile(
          leading: const CircleAvatar(
            radius: 25,
            child: Text('A'),
          ),
          title: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
            child: Text(
              username,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}
