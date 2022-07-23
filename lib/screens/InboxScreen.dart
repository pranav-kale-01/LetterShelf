import 'package:flutter/material.dart';
import 'package:googleapis/gmail/v1.dart' as gmail;
import 'package:letter_shelf/models/emailMessage.dart';
import 'package:letter_shelf/widgets/HomeScreenList.dart';
import 'package:letter_shelf/widgets/bottom_popup_dialog.dart';
import 'package:letter_shelf/widgets/home_screen_search_bar.dart';
import 'package:letter_shelf/widgets/newsletter_search_list.dart';
import 'package:letter_shelf/widgets/search_recommendation.dart';

import '../utils/OAuthClient.dart';
import '../utils/Utils.dart';
import '../widgets/search_filter_button.dart';

class InboxScreen extends StatefulWidget {
  static const stateOpen = 0;
  static const stateClosed = 1;
  bool queryStringBuilt = false;

  final gmail.GmailApi gmailApi;
  final GlobalKey<ScaffoldState> scaffoldKey;

  final double topPadding;
  final double bottomPadding;

  Widget currentDisplayScreen;
  int index;

  List<String> searchQueryFilters = [];

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

  // for showing search filters
  bool showSearchFilters= false;

  String previousSearchValue = "";

  bool externalSearchTriggered = false;

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

  Future<void> addToHomeScreenList( {required String listName, required EmailMessage msg}) async {
    for (HomeScreenList homeScreenTab
        in homeScreenTabsList as List<HomeScreenList>) {
      if (homeScreenTab.key.toString() == listName) {
        // the correct list is found, adding the element to the top of the list
        homeScreenTab.addElementToTop(msg);
      }
    }
  }

  Future<void> removeFromHomeScreenList( {required String listName, required String msgId}) async {
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
      // showing search filters
      showSearchFilters = true;

      // changing current display to search recommendations
      widget.currentDisplayScreen = _searchRecommendationScreen;
    });
  }

  void toggleSearchScreen(bool submitButtonClicked, String searchedText) {
    if (submitButtonClicked) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        setState(() {
          widget.currentDisplayScreen = NewsletterSearchList(
            gmailApi: widget.gmailApi,
            queryStringAddOn: searchedText,
            addToListMethod: addToHomeScreenList,
            removeFromListMethod: removeFromHomeScreenList,
            queryFilters: widget.searchQueryFilters,
            refreshList: true,
          );
        });

        externalSearchTriggered = false;
      });
    }
    else {
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
    if( !externalSearchTriggered ) {
      setState(() {
        initialSearchString = value;

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
  }

  void onExitingSearch() {
    setState(() {
      // hiding search filters
      showSearchFilters = false;

      // resetting the initialString for the next search
      initialSearchString = "";

      // removing previous filters
      widget.searchQueryFilters.clear();
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
          searchTriggeredExternally: externalSearchTriggered,
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
          height: MediaQuery.of(context).size.height - widget.topPadding - widget.bottomPadding,
          child: Column(
            children: [
              if( showSearchFilters )
                Container(
                margin: const EdgeInsets.only(top: 12.0, bottom: 4.0 ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      SearchFilterButton(
                        label: "search in all mails",
                        showDropDownIcon: false,
                        behaviour: SearchFilterButton.toggleButton,
                        onTap: (value) {
                          if( widget.searchQueryFilters.contains(value) ) {
                            widget.searchQueryFilters.remove(value);
                          }
                          else {
                            widget.searchQueryFilters.add(value);
                          }

                          externalSearchTriggered = true;

                          setState(() {
                            // triggering search
                            toggleSearchScreen(true, initialSearchString);
                          });
                        },
                      ),
                      SearchFilterButton(
                        label: "Is unread",
                        showDropDownIcon: false,
                        behaviour: SearchFilterButton.toggleButton,
                        onTap: (value) {
                          if( widget.searchQueryFilters.contains(value) ) {
                            widget.searchQueryFilters.remove(value);
                          }
                          else {
                            widget.searchQueryFilters.add(value);
                          }

                          externalSearchTriggered = true;

                          setState(() {
                            // triggering search
                            toggleSearchScreen(true, initialSearchString);
                          });
                        },
                      ),
                      SearchFilterButton(
                          label: "Labels",
                        onTap: (value) {
                          showDialog(
                            context: context,
                            builder: (context) => BottomPopupDialog(
                              maxFloatingHeight: 0.1,
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.height - widget.topPadding,
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                                      child: Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: const Padding(
                                              padding: EdgeInsets.symmetric( horizontal: 18.0 ),
                                              child: Icon(
                                                Icons.clear
                                              ),
                                            ),
                                          ),
                                          const Text(
                                              "Labels",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold
                                              ),
                                          )
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 4.0),
                                      child: Container(
                                        color: const Color(0xFFBDBDBD),
                                        height: 1,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          Row(
                                            children: [
                                              const Padding(
                                                padding: EdgeInsets.symmetric(horizontal: 8.0,),
                                                child: Icon(
                                                  Icons.star_border_purple500_outlined,
                                                ),
                                              ),
                                              const Padding(
                                                padding: EdgeInsets.symmetric(horizontal: 8.0),
                                                child: Text("Starred"),
                                              ),
                                              Expanded(
                                                child: Container(
                                                  alignment: Alignment.centerRight,
                                                  child: Checkbox(
                                                      value: false,
                                                      onChanged: (value) {},
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              const Padding(
                                                padding: EdgeInsets.symmetric(horizontal: 8.0,),
                                                child: Icon(
                                                  Icons.snooze,
                                                ),
                                              ),
                                              const Padding(
                                                padding: EdgeInsets.symmetric(horizontal: 8.0),
                                                child: Text("Snoozed"),
                                              ),
                                              Expanded(
                                                child: Container(
                                                  alignment: Alignment.centerRight,
                                                  child: Checkbox(
                                                    value: false,
                                                    onChanged: (value) {},
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              const Padding(
                                                padding: EdgeInsets.symmetric(horizontal: 8.0,),
                                                child: Icon(
                                                  Icons.label_important_outline,
                                                ),
                                              ),
                                              const Padding(
                                                padding: EdgeInsets.symmetric(horizontal: 8.0),
                                                child: Text("Important"),
                                              ),
                                              Expanded(
                                                child: Container(
                                                  alignment: Alignment.centerRight,
                                                  child: Checkbox(
                                                    value: false,
                                                    onChanged: (value) {},
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              const Padding(
                                                padding: EdgeInsets.symmetric(horizontal: 8.0,),
                                                child: Icon(
                                                  Icons.send_outlined,
                                                ),
                                              ),
                                              const Padding(
                                                padding: EdgeInsets.symmetric(horizontal: 8.0),
                                                child: Text("Sent"),
                                              ),
                                              Expanded(
                                                child: Container(
                                                  alignment: Alignment.centerRight,
                                                  child: Checkbox(
                                                    value: false,
                                                    onChanged: (value) {},
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            )
                          );
                        },
                      ),
                      SearchFilterButton(
                        label: "Date",
                        onTap: (value) {
                          showDialog(
                            context: context,
                            builder: (context) => BottomPopupDialog(
                              maxFloatingHeight: 0.55,
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width,
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                                      child: Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: const Padding(
                                              padding: EdgeInsets.symmetric( horizontal: 18.0 ),
                                              child: Icon(
                                                  Icons.clear
                                              ),
                                            ),
                                          ),
                                          const Text(
                                            "Date",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 4.0),
                                      child: Container(
                                        color: const Color(0xFFBDBDBD),
                                        height: 1,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                          child: Radio(
                                              value: true,
                                              groupValue: Object(),
                                              onChanged: (_) {},
                                          ),
                                        ),
                                        const Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                                          child: Text("Any Time"),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                          child: Radio(
                                            value: true,
                                            groupValue: Object(),
                                            onChanged: (_) {},
                                          ),
                                        ),
                                        const Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                                          child: Text("Older than a week"),
                                        ),
                                      ],
                                    ),

                                    Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                          child: Radio(
                                            value: true,
                                            groupValue: Object(),
                                            onChanged: (_) {},
                                          ),
                                        ),
                                        const Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                                          child: Text("Older than a month"),
                                        ),
                                      ],
                                    ),

                                    Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                          child: Radio(
                                            value: true,
                                            groupValue: Object(),
                                            onChanged: (_) {},
                                          ),
                                        ),
                                        const Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                                          child: Text("Older than 6 months"),
                                        ),
                                      ],
                                    ),

                                    Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                          child: Radio(
                                            value: true,
                                            groupValue: Object(),
                                            onChanged: (_) {},
                                          ),
                                        ),
                                        const Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                                          child: Text("Older than a year"),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            )
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
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
