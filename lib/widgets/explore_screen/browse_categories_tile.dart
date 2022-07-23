import 'package:flutter/material.dart';
import 'package:letter_shelf/screens/categorized_list.dart';



class BrowseCategoriesTile extends StatelessWidget {
  final String title;

  const BrowseCategoriesTile({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => CategorizedList(keyword: title),
            )
        );
      },
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8)
        ),
        margin: const EdgeInsets.symmetric( horizontal: 6),
        child: Card(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8)
          ),
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0 ,horizontal: 14.0),
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
