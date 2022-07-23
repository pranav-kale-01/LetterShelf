import 'package:flutter/material.dart';

import '../../utils/Utils.dart';
import '../../utils/hive_services.dart';

class SearchRecommendation extends StatefulWidget {
  final String queryString;
  final Function(String) changeSearchString;

  const SearchRecommendation({
    Key? key,
    required this.queryString,
    required this.changeSearchString,
  }) : super(key: key);

  @override
  _SearchRecommendationState createState() => _SearchRecommendationState();
}

class _SearchRecommendationState extends State<SearchRecommendation> {
  HiveServices hiveService = HiveServices();
  List<dynamic> tempList = [];

  @override
  void initState() {
    super.initState();

    init();
  }

  Future<void> init() async {
    String username = Utils.username;
    tempList = await hiveService.getBoxes( username + "SearchRecommendations" );

    setState(() { });
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        widget.queryString.isEmpty ? Container(
          color: Colors.white,
          alignment: Alignment.centerLeft,
          margin: const EdgeInsets.only(top: 12.0, left: 12.0 ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric( vertical: 8.0, ),
                child: Text("Recent email searches"),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: tempList.map( (recommendation) => GestureDetector(
                  onTap: () {
                    widget.changeSearchString( recommendation );
                  },
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only( right: 16.0, top: 4.0, bottom: 4.0),
                          child: Icon(
                            Icons.history_sharp,
                          ),
                        ),
                        Text(recommendation.toString())
                      ],
                    ),
                  ),
                ) ).toList()
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
              Text("Search for '${widget.queryString}' in emails"),
            ],
          ),
        )
      ],
    );
  }
}
