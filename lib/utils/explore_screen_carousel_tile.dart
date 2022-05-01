import 'package:flutter/material.dart';

class ExploreScreenCarouselTile extends StatelessWidget {
  final String title;
  final Image image;

  const ExploreScreenCarouselTile({Key? key, required this.title, required this.image}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        debugPrint('tapped');
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15)
        ),
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.symmetric(horizontal: 5),
        child: Stack(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: image
              ),
            ),
            Container(
              decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(15)
              ),
              width: MediaQuery.of(context).size.width,
            ),
            Center(
              child: SizedBox(
                  width: MediaQuery.of(context).size.width / 1.3,
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 28,
                      color: Colors.white,
                    ),
                    maxLines: 3,
                    textAlign: TextAlign.center,
                  )
              ),
            )
          ],
        ),
      ),
    );
  }
}
