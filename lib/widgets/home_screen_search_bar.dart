import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../utils/Utils.dart';
import '../utils/hive_services.dart';

class HomeScreenSearchBar extends StatefulWidget {
  String initialString;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final Function(bool, String) triggerSearchScreen;
  final Function() showSearchRecommendation;
  final Function(String) onQueryStringChange;
  final VoidCallback onSearchExiting;
  String externalSearchValue;
  bool reset;

  // defines if the search was triggered externally
  bool searchTriggeredExternally;

  HomeScreenSearchBar({
    Key? key,
    required this.initialString,
    required this.scaffoldKey,
    required this.triggerSearchScreen,
    required this.showSearchRecommendation,
    required this.onQueryStringChange,
    required this.onSearchExiting,
    this.externalSearchValue = "",
    this.searchTriggeredExternally = false,
    required this.reset }) : super(key: key);

  @override
  _HomeScreenSearchBarState createState() => _HomeScreenSearchBarState();
}

class _HomeScreenSearchBarState extends State<HomeScreenSearchBar> with SingleTickerProviderStateMixin {
  // behaviour properties
  TextEditingController searchBarTextController = TextEditingController();
  final FocusNode searchBarFocusNode = FocusNode();
  bool searchTriggered = false;

  // searchbar Properties
  late Icon menuIcon;
  late double searchBarElevation;

  // animation properties
  double turns = 0.0;
  bool isClicked = false;
  bool rotationAllowed = true;

  late AnimationController _elevationController;
  late Animation _elevationAnimation;

  // local storage
  HiveServices hiveService = HiveServices();

  // for search bar
  String previousValue = "";
  bool updateText = true;

  @override
  void initState() {
    super.initState();

    // adding listener to searchBarTextController
    searchBarTextController.addListener(() {
      widget.onQueryStringChange(  searchBarTextController.text );
    });

    // animation for elevation
    _elevationController = AnimationController(
      vsync: this,
      duration: const Duration( milliseconds: 100 ),
    );

    _elevationAnimation = Tween<double>(begin: 0.0, end: 5.0)
        .chain(CurveTween(curve: Curves.ease))
        .animate(_elevationController)
      ..addListener(() {
        setState(() {});
      });

    _elevationController.forward();

    menuIcon = const Icon( Icons.menu, color: Colors.black, );
  }

  void menuIconBehaviour() {
    if( searchBarFocusNode.hasFocus ) {
      // behaviour for back button
      setState(() {
        // searchBarElevation = 3;
        _elevationController.forward();
        menuIcon = const Icon( Icons.menu , color: Colors.black,);

        FocusScope.of(context).requestFocus(FocusNode());
      });
    }
    else {
      // behaviour for menu button
      widget.scaffoldKey.currentState!.openDrawer();
    }
  }

  void rotate() {
    if( isClicked ) {
      setState(() {
        turns -= 1/4;
      });
    }
    else {
      setState(() {
        turns += 1/4;
      });
    }
    isClicked = !isClicked;
  }

  @override
  Widget build(BuildContext context) {
    if( widget.searchTriggeredExternally ) {
      updateText = false;
      searchBarFocusNode.unfocus();

      // saving the current search string for future recommendations
      String username = Utils.username;

      hiveService.getBoxes( username + "SearchRecommendations" ).then((tempList) async {
        // checking if the search string is already one of the recommendations, if yes then removing that particular recommendation from the list
        if( tempList.contains(searchBarTextController.text) ) {
          tempList.remove(searchBarTextController.text);
        }

        // limiting the list to contain only 6 elements at max
        if( tempList.length > 5 ) {
          tempList.removeLast();
        }

        // inserting the current recommendation in the list of recommendations
        tempList.insert(0, searchBarTextController.text);

        // deleting the old values
        Box _box = await Hive.openBox( username + "SearchRecommendations" );
        _box.deleteAll(_box.keys);

        // adding the new list
        await hiveService.addBoxes(  tempList, username + "SearchRecommendations");
      });

      // triggering the search screen
      searchTriggered = true;
      widget.triggerSearchScreen(true, searchBarTextController.text);

      widget.searchTriggeredExternally = false;
    }

    if( updateText ) {
      searchBarTextController = TextEditingController( text: widget.initialString );
      searchBarTextController.selection = TextSelection.fromPosition(
        TextPosition(
          offset: searchBarTextController.text.length,
        ),
      );
    }
    else {
      updateText = true;
    }

    if( widget.reset ) {
      widget.reset = false;

      searchTriggered = false;

      // rotating the button and changing the flag to avoid repetition
      rotate();
      rotationAllowed = !rotationAllowed;

      // adding back elevation to the search bar
      searchBarElevation = 3;

      // changing the menu icon
      menuIcon = const Icon( Icons.menu, color: Colors.black, );

      // removing focus from the text field and clearing previous data
      FocusScope.of(context).requestFocus(FocusNode());
      searchBarTextController.clear();
    }

    return WillPopScope(
      onWillPop: () async {
        // clearing previous value
        previousValue = "";

        searchBarTextController.text = "";

        widget.onSearchExiting();

        rotate();
        rotationAllowed = !rotationAllowed;

        // adding back elevation to the search bar
        // searchBarElevation = 3;
        _elevationController.forward();

        // changing the menu icon
        menuIcon = const Icon( Icons.menu, color: Colors.black, );

        // removing focus from the text field and clearing previous data
        FocusScope.of(context).requestFocus(FocusNode());
        searchBarTextController.clear();

        // closing the searchScreen
        widget.triggerSearchScreen(false, '');

        setState(() { });
        return false;
      },
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: AnimatedPadding(
          duration: const Duration( milliseconds: 600),
          curve: Curves.easeOutExpo,
          padding: EdgeInsets.zero,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)
            ),
            elevation: _elevationAnimation.value,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Search Bar
                AnimatedRotation(
                  curve: Curves.easeOutExpo,
                  duration: const Duration( milliseconds: 600),
                  turns: turns,
                  child: GestureDetector(
                    onTap: () {
                      if( searchBarFocusNode.hasFocus || searchTriggered) {
                          widget.onSearchExiting();

                          // clearing previous value
                          previousValue = "";

                          searchTriggered = false;

                          // rotating the button and changing the flag to avoid repetition
                          rotate();
                          rotationAllowed = !rotationAllowed;

                          // adding back elevation to the search bar
                          // searchBarElevation = 3;
                          _elevationController.forward();

                          // changing the menu icon
                          menuIcon = const Icon( Icons.menu, color: Colors.black, );

                          // removing focus from the text field and clearing previous data
                          FocusScope.of(context).requestFocus(FocusNode());
                          searchBarTextController.clear();

                          // closing the searchScreen
                          widget.triggerSearchScreen(false, '' );

                          setState(() { });
                        }
                      else {
                        // behaviour for menu button
                        widget.scaffoldKey.currentState!.openDrawer();
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.only(left: 3),
                      padding: const EdgeInsets.symmetric( horizontal: 8.0 ),
                      child: menuIcon,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only( left: 5 ),
                    child: TextField(
                      controller: searchBarTextController,
                      onChanged: (value) {
                        widget.onQueryStringChange(searchBarTextController.text);
                      },
                      onSubmitted: (value) async {
                        if( searchBarTextController.text.isNotEmpty ) {
                          updateText = false;
                          widget.onQueryStringChange( searchBarTextController.text );

                          searchBarFocusNode.unfocus();

                          // saving the current search string for future recommendations
                          String username = Utils.username;
                          List<dynamic> tempList = await hiveService.getBoxes( username + "SearchRecommendations" );

                          // checking if the search string is already one of the recommendations, if yes then removing that particular recommendation from the list
                          if( tempList.contains(searchBarTextController.text) ) {
                            tempList.remove(searchBarTextController.text);
                          }

                          // limiting the list to contain only 6 elements at max
                          if( tempList.length > 5 ) {
                            tempList.removeLast();
                          }

                          // inserting the current recommendation in the list of recommendations
                          tempList.insert(0, searchBarTextController.text);

                          // deleting the old values
                          Box _box = await Hive.openBox( username + "SearchRecommendations" );
                          _box.deleteAll(_box.keys);

                          // adding the new list
                          await hiveService.addBoxes(  tempList, username + "SearchRecommendations");

                          // triggering the search screen
                          searchTriggered = true;
                          widget.triggerSearchScreen(true, searchBarTextController.text);
                        }
                        else {
                          rotate();
                          rotationAllowed = !rotationAllowed;

                          // adding back elevation to the search bar
                          // searchBarElevation = 3;
                          _elevationController.forward();

                          // changing the menu icon
                          menuIcon = const Icon( Icons.menu, color: Colors.black, );

                          // removing focus from the text field and clearing previous data
                          FocusScope.of(context).requestFocus(FocusNode());
                          searchBarTextController.clear();

                          // closing the searchScreen
                          widget.triggerSearchScreen(false, '');


                          setState(() { });
                        }
                      },
                      onTap: () {
                        setState(() {
                          widget.initialString = "";

                          // giving a pop effect by reducing the padding and removing the elevation of the searchBar
                          if( rotationAllowed ) {
                            rotate();
                            rotationAllowed = !rotationAllowed;
                          }

                          _elevationController.reverse();
                          // searchBarElevation = 0;

                          menuIcon = const Icon( Icons.arrow_downward, color: Colors.black, );
                          widget.showSearchRecommendation();
                        });
                      },
                      focusNode: searchBarFocusNode,
                      decoration: const InputDecoration(
                        hintText: "Search in Newsletters",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
