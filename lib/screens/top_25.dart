import 'package:flutter/material.dart';

class Top25 extends StatelessWidget {
  const Top25({Key? key}) : super(key: key);

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
