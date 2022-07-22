import 'package:flutter/material.dart';
import 'package:googleapis/gmail/v1.dart' as gmail;
import 'package:letter_shelf/models/emailMessage.dart';
import 'package:letter_shelf/widgets/HomeScreenList.dart';
import 'package:letter_shelf/widgets/home_screen_search_bar.dart';
import 'package:letter_shelf/widgets/newsletter_search_list.dart';
import 'package:letter_shelf/widgets/search_recommendation.dart';

import '../utils/OAuthClient.dart';
import '../utils/Utils.dart';

class InboxScreen extends StatefulWidget {
  static const stateOpen = 0;
  static const stateClosed = 1;

  final gmail.GmailApi gmailApi;
  final GlobalKey<ScaffoldState> scaffoldKey;
  bool queryStringBuilt = false;
  final double topPadding;
  final double bottomPadding;
  Widget currentDisplayScreen;
  int index;

  InboxScreen({
    Key? key,
    required this.gmailApi,
    required this.topPadding,
    required this.bottomPadding,
    required this.scaffoldKey,
    required this.currentDisplayScreen,
    required this.index,
  }) : super(key: key);

  @override
  _InboxScreenState createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  late String username;
  String queryString = "";
  late List<Widget> homeScreenTabsList;
  late AppBar _appBar;
  Widget? previousScreen;
  late Widget _searchRecommendationScreen;

  int selectedDrawer = 0;

  bool firstTimeSearchTriggered = false;
  bool _reset = false;

  String initialSearchString = "";

  @override
  void initState() {
    super.initState();

    // setting the current screen as previous screen
    previousScreen = widget.currentDisplayScreen;

    _searchRecommendationScreen = SearchRecommendation(
      queryString: '',
      changeSearchString: changeSearchString,
    );

    init();
  }

  Future<void> init() async {
    Utils.username = await OAuthClient.getCurrentUserNameFromApi(widget.gmailApi);
  }

  Future<void> addToHomeScreenList(
      {required String listName, required EmailMessage msg}) async {
    for (HomeScreenList homeScreenTab
        in homeScreenTabsList as List<HomeScreenList>) {
      if (homeScreenTab.key.toString() == listName) {
        // the correct list is found, adding the element to the top of the list
        homeScreenTab.addElementToTop(msg);
      }
    }
  }

  Future<void> removeFromHomeScreenList(
      {required String listName, required String msgId}) async {
    for (HomeScreenList homeScreenTab
        in homeScreenTabsList as List<HomeScreenList>) {
      if (homeScreenTab.key.toString() == listName) {
        // the correct list is found, removing the element from the list
        homeScreenTab.removeElement(msgId);
      }
    }
  }

  void showRecommendationScreen() {
    setState(() {
      widget.currentDisplayScreen = _searchRecommendationScreen;
    });
  }

  void toggleSearchScreen(bool submitButtonClicked, String searchedText) {
    if (submitButtonClicked) {
      setState(() {
        widget.currentDisplayScreen = NewsletterSearchList(
          gmailApi: widget.gmailApi,
          queryStringAddOn: searchedText,
          addToListMethod: addToHomeScreenList,
          removeFromListMethod: removeFromHomeScreenList,
        );
      });
    } else {
      if (!submitButtonClicked) {
        firstTimeSearchTriggered = false;
      }

      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        setState(() {
          widget.currentDisplayScreen = previousScreen!;
        });
      });
    }
  }

  void onSearchStringChanged(String value) {
    setState(() {
      widget.currentDisplayScreen = WillPopScope(
        onWillPop: () async {
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            setState(() {
              widget.currentDisplayScreen = previousScreen!;
              _reset = true;
            });
          });

          return false;
        },
        child: SearchRecommendation(
          queryString: value,
          changeSearchString: changeSearchString,
        ),
      );
    });
  }

  void onExitingSearch() {
    setState(() {
      initialSearchString = "";
    });
  }

  void changeSearchString( String newValue ) {
    initialSearchString = newValue;
    onSearchStringChanged(newValue);
    setState(() { });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    _appBar = AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      titleTextStyle: const TextStyle(color: Colors.black, fontSize: 22),
      iconTheme: const IconThemeData(
        color: Colors.black,
      ),
      actions: [
        HomeScreenSearchBar(
          initialString: initialSearchString,
          scaffoldKey: widget.scaffoldKey,
          triggerSearchScreen: toggleSearchScreen,
          showSearchRecommendation: showRecommendationScreen,
          reset: _reset,
          onQueryStringChange: onSearchStringChanged,
          onSearchExiting: onExitingSearch,
        ),
      ],
    );

    _reset = false;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: _appBar,
        body: SizedBox(
          height: MediaQuery.of(context).size.height -
              widget.topPadding -
              widget.bottomPadding,
          child: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height -
                    _appBar.preferredSize.height -
                    widget.topPadding -
                    widget.bottomPadding -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom -
                    10,
                child: widget.currentDisplayScreen,
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
    Utils.firstHomeScreenLoad = false;
    super.dispose();
  }
}
