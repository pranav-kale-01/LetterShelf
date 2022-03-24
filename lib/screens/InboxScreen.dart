import 'package:flutter/material.dart';
import 'package:googleapis/gmail/v1.dart' as gmail;
import 'package:letter_shelf/models/emailMessage.dart';
import 'package:letter_shelf/widgets/HomeScreenList.dart';



class InboxScreen extends StatefulWidget {
  final gmail.GmailApi gmailApi;
  bool queryStringBuilt = false;
  final double topPadding;
  final double bottomPadding;

  InboxScreen(
      {Key? key,
      required this.gmailApi,
      required this.topPadding,
      required this.bottomPadding})
      : super(key: key);

  @override
  _InboxScreenState createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen>
    with AutomaticKeepAliveClientMixin {
  late String queryString;
  late List<HomeScreenList> homeScreenTabsList;
  late AppBar _appBar;

  @override
  void initState() {
    super.initState();

    // initializing appbar
    _appBar = AppBar(
      title: const Text('LetterShelf'),
      backgroundColor: Colors.white,
      elevation: 0,
      titleTextStyle: const TextStyle(color: Colors.black, fontSize: 22),
    );

    homeScreenTabsList = [
      HomeScreenList(
        key: const Key('UNREAD'),
        gmailApi: widget.gmailApi,
        queryStringAddOn: ' is:unread ',
        addToListMethod: addToHomeScreenList,
        removeFromListMethod: removeFromHomeScreenList,
      ),
      HomeScreenList(
        key: const Key('READ'),
        gmailApi: widget.gmailApi,
        queryStringAddOn: ' is:read ',
        addToListMethod: addToHomeScreenList,
        removeFromListMethod: removeFromHomeScreenList,
      ),
    ];
  }

  Future<void> addToHomeScreenList(
      {required String listName, required EmailMessage msg}) async {
    for (HomeScreenList homeScreenTab in homeScreenTabsList) {
      if (homeScreenTab.key.toString() == listName) {
        // the correct list is found, adding the element to the top of the list
        homeScreenTab.addElementToTop(msg);
      }
    }
  }

  Future<void> removeFromHomeScreenList(
      {required String listName, required String msgId}) async {
    for (HomeScreenList homeScreenTab in homeScreenTabsList) {
      if (homeScreenTab.key.toString() == listName) {
        // the correct list is found, removing the element from the list
        homeScreenTab.removeElement(msgId);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: _appBar,
        body: SafeArea(
          child: SizedBox(
            height: MediaQuery.of(context).size.height -
                _appBar.preferredSize.height -
                widget.topPadding -
                widget.bottomPadding,
            child: Column(
              children: [
                /// TODO: implement Searchbar here
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  alignment: Alignment.centerLeft,
                  height: (MediaQuery.of(context).size.height -
                          _appBar.preferredSize.height -
                          widget.topPadding -
                          widget.bottomPadding) *
                      0.05,
                  child: TabBar(
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.blueAccent,
                    ),
                    indicatorSize: TabBarIndicatorSize.label,
                    isScrollable: true,
                    tabs: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.black26,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Tab(text: 'Unread'),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.black26,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: const Tab(text: 'Read'),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: (MediaQuery.of(context).size.height -
                          _appBar.preferredSize.height -
                          widget.topPadding -
                          widget.bottomPadding) *
                      0.84,
                  child: TabBarView(
                    children: homeScreenTabsList,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    super.dispose();
  }
}
