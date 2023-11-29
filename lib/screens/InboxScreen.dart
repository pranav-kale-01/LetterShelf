import 'package:flutter/material.dart';
import 'package:googleapis/gmail/v1.dart' as gmail;
import 'package:letter_shelf/models/emailMessage.dart';

import 'package:letter_shelf/widgets/home_screen/HomeScreenList.dart';
import 'package:letter_shelf/widgets/home_screen/date_filter_bottom_dialog.dart';
import 'package:letter_shelf/widgets/home_screen/home_screen_search_bar.dart';
import 'package:letter_shelf/widgets/home_screen/labels_bottom_dialog.dart';

import 'package:letter_shelf/widgets/home_screen/newsletter_search_list.dart';
import 'package:letter_shelf/widgets/home_screen/search_filter_button.dart';
import 'package:letter_shelf/widgets/home_screen/search_recommendation.dart';

import '../utils/OAuthClient.dart';
import '../utils/Utils.dart';


class InboxScreen extends StatefulWidget {
  // static values
  static const stateOpen = 0;
  static const stateClosed = 1;

  bool queryStringBuilt = false;

  final gmail.GmailApi gmailApi;
  final GlobalKey<ScaffoldState> scaffoldKey;

  final double topPadding;
  final double bottomPadding;

  Widget currentDisplayScreen;
  int index;

  Map<String,dynamic> searchQueryFilters = {};

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

class _InboxScreenState extends State<InboxScreen> with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {

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

  // for storing labels
  Map<String,dynamic> labels = {
    "starred" : false,
    "snoozed" : false,
    "important" : false,
    "sent" : false,
  };

  // for date filters
  List<String> dateFilters = [
    "any time",
    "older than a week",
    "older than a month",
    "older than 6 months",
    "older than a year",
  ];

  String initialDateFilter = "any time";

  // for label icons
  final Map<String, IconData> labelIcons = {
    "starred" : Icons.star_outline_rounded,
    "snoozed" : Icons.snooze_sharp,
    "important" : Icons.label_important_outline_sharp,
    "sent" : Icons.send_outlined,
  };

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
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        appBar: _appBar,
        body: SizedBox(
          height: MediaQuery.of(context).size.height - widget.topPadding - widget.bottomPadding,
          child: Column(
            children: [
              if( showSearchFilters )
                Container(
                  margin: const EdgeInsets.only(top: 8.0, bottom: 8.0 ),
                  color: Colors.white,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        SearchFilterButton(
                          label: "search in all mails",
                          showDropDownIcon: false,
                          behaviour: SearchFilterButton.toggleButton,
                          onTap: (value) {
                            if( widget.searchQueryFilters[value] == null || widget.searchQueryFilters[value] == false ) {
                              widget.searchQueryFilters.addAll( {value:true} );
                            }
                            else {
                              widget.searchQueryFilters.addAll( {value:false} );
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
                            if( widget.searchQueryFilters[value] == null || widget.searchQueryFilters[value] == false ) {
                              widget.searchQueryFilters.addAll( {value:true} );
                            }
                            else {
                              widget.searchQueryFilters.addAll( {value:false} );
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
                              builder: (context) => LabelsBottomDialog(
                                topPadding: widget.topPadding,
                                labels: labels,
                                labelIcons: labelIcons,
                              ),
                            ).then( (_) {
                              widget.searchQueryFilters.addAll({ "labels": labels });

                              setState(() {
                                // triggering search
                                toggleSearchScreen(true, initialSearchString);
                              });
                            });
                          },
                        ),
                        SearchFilterButton(
                          label: "Date",
                          onTap: (value) {
                            showDialog(
                              context: context,
                              builder: (context) => DateFilterBottomDialog(
                                topPadding: widget.topPadding,
                                dateFilters: dateFilters,
                                initialDateFilter: initialDateFilter,
                                notifyParent: (value) {
                                  initialDateFilter = value;

                                  for( String i in dateFilters ) {
                                    if( i == value ) {
                                      initialDateFilter = value;
                                    }
                                  }

                                  widget.searchQueryFilters.addAll( {"date" : initialDateFilter } );

                                  setState(() {
                                    // triggering search
                                    toggleSearchScreen(true, initialSearchString);
                                  });
                                },
                              ),
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

    widget.currentDisplayScreen = previousScreen!;
    _reset = true;

    Utils.firstHomeScreenLoad = false;
    super.dispose();
  }
}