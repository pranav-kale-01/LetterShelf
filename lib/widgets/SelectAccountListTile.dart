import 'package:flutter/material.dart';

import '../utils/Utils.dart';


class SelectAcccountListTile extends StatelessWidget {
  final String username;

  const SelectAcccountListTile({Key? key, required this.username}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: ListTile(
          leading: CircleAvatar(
            radius: 26,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Text(
                  Utils.getInitials(username),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20
                  ),
              ),
            ),
          ),
          title: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
            child: Text(
              username,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 20
              ),
            ),
          ),
        ),
      ),
    );
  }
}
