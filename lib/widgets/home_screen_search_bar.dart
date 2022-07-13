import 'package:flutter/material.dart';
class HomeScreenSearchBar extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final Function(bool, String) triggerSearchScreen;
  final Function() showSearchRecommendation;

  const HomeScreenSearchBar({Key? key, required this.scaffoldKey, required this.triggerSearchScreen, required this.showSearchRecommendation}) : super(key: key);

  @override
  _HomeScreenSearchBarState createState() => _HomeScreenSearchBarState();
}

class _HomeScreenSearchBarState extends State<HomeScreenSearchBar> {
  // behaviour properties
  final TextEditingController searchBarTextController = TextEditingController();
  final FocusNode searchBarFocusNode = FocusNode();
  bool searchTriggered = false;

  // searchbar Properties
  late Icon menuIcon;
  late EdgeInsets searchBarPadding;
  late double searchBarElevation;

  // animation properties
  double turns = 0.0;
  bool isClicked = false;
  bool rotationAllowed = true;


  @override
  void initState() {
    super.initState();

    searchBarPadding = const EdgeInsets.symmetric(horizontal: 5.0);
    searchBarElevation = 3.0;
    // animatedMenuButton = AnimatedMenuButton(menuIcon: menuIcon, buttonOnPressed: menuIconBehaviour );

    menuIcon = const Icon( Icons.menu, color: Colors.black, );
  }

  void menuIconBehaviour() {
    if( searchBarFocusNode.hasFocus ) {
      // behaviour for back button
      setState(() {
        searchBarElevation = 3;
        searchBarPadding = const EdgeInsets.symmetric(horizontal: 5.0, );
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
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: AnimatedPadding(
        duration: const Duration( milliseconds: 600),
        curve: Curves.easeOutExpo,
        padding: searchBarPadding,
        child: Card(
          elevation: searchBarElevation,
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
                        searchTriggered = false;

                        // rotating the button and changing the flag to avoid repetition
                        rotate();
                        rotationAllowed = !rotationAllowed;

                        // adding back elevation to the search bar
                        searchBarElevation = 3;
                        searchBarPadding = const EdgeInsets.symmetric(horizontal: 5.0, );

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
                    child: IconButton(
                      icon: menuIcon,
                      onPressed: null,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only( left: 5 ),
                  child: TextField(
                    controller: searchBarTextController,
                    onSubmitted: (value) {
                      if( searchBarTextController.text.isNotEmpty ) {
                        searchBarFocusNode.unfocus();
                        searchTriggered = true;
                        widget.triggerSearchScreen(true, value);
                      }
                      else {
                        rotate();
                        rotationAllowed = !rotationAllowed;

                        // adding back elevation to the search bar
                        searchBarElevation = 3;
                        searchBarPadding = const EdgeInsets.symmetric(horizontal: 5.0, );

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
                        // giving a pop effect by reducing the padding and removing the elevation of the searchBar
                        if( rotationAllowed ) {
                          rotate();
                          rotationAllowed = !rotationAllowed;
                        }

                        searchBarElevation = 0;
                        searchBarPadding = EdgeInsets.zero;

                        menuIcon = const Icon( Icons.arrow_downward, color: Colors.black, );
                        widget.showSearchRecommendation();
                      });
                    },
                    focusNode: searchBarFocusNode,
                    decoration: const InputDecoration(
                      hintText: "Search in Newsletters",
                      hintStyle: TextStyle(
                        fontSize: 18,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
