import 'package:flutter/material.dart';
class HomeScreenSearchBar extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final Function(bool, String) triggerSearchScreen;
  final Function() showSearchRecommendation;
  final Function(String) onQueryStringChange;
  bool reset;

  HomeScreenSearchBar({
    Key? key,
    required this.scaffoldKey,
    required this.triggerSearchScreen,
    required this.showSearchRecommendation,
    required this.onQueryStringChange,
    required this.reset }) : super(key: key);

  @override
  _HomeScreenSearchBarState createState() => _HomeScreenSearchBarState();
}

class _HomeScreenSearchBarState extends State<HomeScreenSearchBar> with SingleTickerProviderStateMixin {
  // behaviour properties
  final TextEditingController searchBarTextController = TextEditingController();
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

    return SizedBox(
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
    );
  }
}
