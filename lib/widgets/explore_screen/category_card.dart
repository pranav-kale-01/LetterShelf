import 'package:flutter/material.dart';
import 'package:letter_shelf/screens/categorized_list.dart';

class CategoryCard extends StatelessWidget {
  final String text;
  Color? backgroundColor;
  final Image image;
  final Color textColor;

  CategoryCard({Key? key, required this.text, required this.image, this.textColor = Colors.white}) : super(key: key);

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
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            margin: const EdgeInsets.all(4.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: image,
            ),
          ),
          Container(
            margin: const EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.black54,
            ),
          ),
          Container(
            margin: const EdgeInsets.all(4.0),
            decoration: BoxDecoration(
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
        ],

      ),
    );
  }
}
