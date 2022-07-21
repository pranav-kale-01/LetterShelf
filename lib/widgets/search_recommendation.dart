import 'package:flutter/material.dart';
import 'package:letter_shelf/widgets/search_filter_button.dart';

class SearchRecommendation extends StatelessWidget {
  String queryString;

  SearchRecommendation({
    Key? key,
    required this.queryString
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 4.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: const [
                SearchFilterButton(
                    label: "Labels"
                ),
                SearchFilterButton(
                    label: "From"
                ),
                SearchFilterButton(
                    label: "Date"
                ),
                SearchFilterButton(
                  label: "Is unread",
                  showDropDownIcon: false,
                ),
                SearchFilterButton(
                    label: "To"
                ),
              ],
            ),
          ),
        ),
        queryString.isEmpty ? Container(
          alignment: Alignment.centerLeft,
          margin: const EdgeInsets.only(top: 12.0, left: 8.0 ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric( vertical: 8.0, ),
                child: Text("Recent email searches"),
              ),
              Column(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      children: const [
                        Padding(
                          padding: EdgeInsets.only( right: 16.0, top: 4.0, bottom: 4.0),
                          child: Icon(
                            Icons.history_sharp,
                          ),
                        ),
                        Text("Recent Search 1")
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      children: const [
                        Padding(
                          padding: EdgeInsets.only( right: 16.0, top: 4.0, bottom: 4.0),
                          child: Icon(
                            Icons.history_sharp,
                          ),
                        ),
                        Text("Recent Search 2")
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      children: const [
                        Padding(
                          padding: EdgeInsets.only( right: 16.0, top: 4.0, bottom: 4.0),
                          child: Icon(
                            Icons.history_sharp,
                          ),
                        ),
                        Text("Recent Search 3")
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      children: const [
                        Padding(
                          padding: EdgeInsets.only( right: 16.0, top: 4.0, bottom: 4.0),
                          child: Icon(
                            Icons.history_sharp,
                          ),
                        ),
                        Text("Recent Search 4")
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        ) : Container(
          margin: const EdgeInsets.only(top: 12.0, left: 8.0 ),
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric( horizontal: 4.0),
                child: Icon(
                  Icons.find_in_page_outlined,
                ),
              ),
              Text("Search for '$queryString' in emails"),
            ],
          ),
        )
      ],
    );
  }
}
