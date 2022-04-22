import 'package:flutter/material.dart';
import 'package:googleapis/gmail/v1.dart' as gmail;
import 'package:letter_shelf/models/emailMessage.dart';
import 'package:letter_shelf/widgets/HomeScreenList.dart';
import 'package:letter_shelf/widgets/home_screen_drawer.dart';
import 'package:letter_shelf/widgets/home_screen_search_bar.dart';
import 'package:letter_shelf/widgets/newsletter_search_list.dart';

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

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();


  late String queryString;
  late List<HomeScreenList> homeScreenTabsList;
  late AppBar _appBar;
  late Widget currentDisplayScreen;
  late Widget previousScreen;
  Widget? mainScreen;

  bool firstTimeSearchTriggered = false;


  @override
  void initState() {
    super.initState();

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

    currentDisplayScreen = homeScreenTabsList[0];
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

  void setNewScreen( int index ) {
    setState(() {
      currentDisplayScreen = homeScreenTabsList[index];
      mainScreen = currentDisplayScreen;
      firstTimeSearchTriggered = true;
    });

    _scaffoldKey.currentState!.openEndDrawer();
  }

  void showRecommendationScreen() {
    if( mainScreen == null ) {
      mainScreen = currentDisplayScreen;
    }

    previousScreen = mainScreen!;

    setState(() {
      currentDisplayScreen = Container();
    });
  }

  void toggleSearchScreen( bool submitButtonClicked, String searchedText ) {
    if( submitButtonClicked ) {

      setState(() {
        currentDisplayScreen = NewsletterSearchList(
          gmailApi: widget.gmailApi,
          queryStringAddOn: searchedText,
          addToListMethod: addToHomeScreenList,
          removeFromListMethod: removeFromHomeScreenList,
        );
      });
    }
    else {
      if( !submitButtonClicked ) {
        firstTimeSearchTriggered = false;
      }

      setState(() {
        currentDisplayScreen = previousScreen;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    _appBar = AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      titleTextStyle: const TextStyle(color: Colors.black, fontSize: 22),
      iconTheme: const IconThemeData(
        color: Colors.black,
      ),
      actions: [
        HomeScreenSearchBar(scaffoldKey: _scaffoldKey, triggerSearchScreen: toggleSearchScreen, showSearchRecommendation: showRecommendationScreen, ),
      ],
    );

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        key: _scaffoldKey,
        drawer: HomeScreenDrawer( notifyParent: setNewScreen, displayScreen: currentDisplayScreen, displayOptions: homeScreenTabsList ),
        appBar: _appBar,
        body: SizedBox(
          height: MediaQuery.of(context).size.height - widget.topPadding - widget.bottomPadding,
          child: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height - _appBar.preferredSize.height - widget.topPadding - widget.bottomPadding - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom - 10,
                child: currentDisplayScreen,
              ),
            ],
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
