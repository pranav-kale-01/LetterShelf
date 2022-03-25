import 'package:flutter/material.dart';
import 'package:letter_shelf/screens/categorized_list.dart';

class CategoryCard extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;

  const CategoryCard({Key? key, required this.text, required this.backgroundColor, this.textColor = Colors.white}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CategorizedList(keyword: text),
          )
        );
      },
      child: Container(
        margin: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style:  TextStyle(
              fontSize: 20,
              color: textColor,
              fontWeight: FontWeight.w400),
        ),
      ),
    );
  }
}
