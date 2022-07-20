import 'package:flutter/material.dart';
import 'package:googleapis/gmail/v1.dart' as gmail;
import 'package:letter_shelf/models/emailMessage.dart';
import 'package:letter_shelf/widgets/HomeScreenList.dart';
import 'package:letter_shelf/widgets/home_screen_drawer.dart';
import 'package:letter_shelf/widgets/home_screen_search_bar.dart';
import 'package:letter_shelf/widgets/newsletter_search_list.dart';

import '../utils/OAuthClient.dart';
import '../utils/Utils.dart';
import '../widgets/mail_display_list.dart';
import '../widgets/saved_screen_list.dart';

class InboxScreen extends StatefulWidget {
  static const stateOpen = 0;
  static const stateClosed = 1;

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
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();


  late String queryString;
  late List<Widget> homeScreenTabsList;
  late AppBar _appBar;
  late Widget currentDisplayScreen;
  late Widget previousScreen;

  int selectedDrawer=0;
  Widget? mainScreen;

  bool firstTimeSearchTriggered = false;

  late AnimationController _controller;
  late Animation _animation;

  @override
  void initState() {
    super.initState();

    // animation for opening sidebar
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));

    _animation = Tween<double>(begin: 0, end: 20.0)
        .chain(CurveTween(curve: Curves.ease))
        .animate(_controller)
      ..addListener(() {
        setState(() {});
    });

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
      SavedScreenList( ),
      MailDisplayList(
        key: const Key('INBOX'),
        gmailApi: widget.gmailApi,
        queryStringAddOn: ' is:inbox ',
        addToListMethod: addToHomeScreenList,
        removeFromListMethod: removeFromHomeScreenList,
      ),
      MailDisplayList(
        key: const Key('IMPORTANT'),
        gmailApi: widget.gmailApi,
        queryStringAddOn: ' is:important ',
        addToListMethod: addToHomeScreenList,
        removeFromListMethod: removeFromHomeScreenList,
      ),
      MailDisplayList(
        key: const Key('UNREAD MAILS'),
        gmailApi: widget.gmailApi,
        queryStringAddOn: ' is:unread ',
        addToListMethod: addToHomeScreenList,
        removeFromListMethod: removeFromHomeScreenList,
      ),
      MailDisplayList(
        key: const Key('STARRED'),
        gmailApi: widget.gmailApi,
        queryStringAddOn: ' is:starred ',
        addToListMethod: addToHomeScreenList,
        removeFromListMethod: removeFromHomeScreenList,
      ),
      MailDisplayList(
        key: const Key('SNOOZED'),
        gmailApi: widget.gmailApi,
        queryStringAddOn: ' is:snoozed ',
        addToListMethod: addToHomeScreenList,
        removeFromListMethod: removeFromHomeScreenList,
      ),
      MailDisplayList(
        key: const Key('SENT'),
        gmailApi: widget.gmailApi,
        queryStringAddOn: ' in:sent ',
        addToListMethod: addToHomeScreenList,
        removeFromListMethod: removeFromHomeScreenList,
      ),
      MailDisplayList(
        key: const Key('SCHEDULED'),
        gmailApi: widget.gmailApi,
        queryStringAddOn: ' in:scheduled ',
        addToListMethod: addToHomeScreenList,
        removeFromListMethod: removeFromHomeScreenList,
      ),
      MailDisplayList(
        key: const Key('OUTBOX'),
        gmailApi: widget.gmailApi,
        queryStringAddOn: ' is:outbox ',
        addToListMethod: addToHomeScreenList,
        removeFromListMethod: removeFromHomeScreenList,
      ),
      MailDisplayList(
        key: const Key('DRAFTS'),
        gmailApi: widget.gmailApi,
        queryStringAddOn: ' is:draft ',
        addToListMethod: addToHomeScreenList,
        removeFromListMethod: removeFromHomeScreenList,
      ),

      MailDisplayList(
        key: const Key('ALL MAILS'),
        gmailApi: widget.gmailApi,
        queryStringAddOn: ' ',
        addToListMethod: addToHomeScreenList,
        removeFromListMethod: removeFromHomeScreenList,
      ),

      MailDisplayList(
        key: const Key('SPAM'),
        gmailApi: widget.gmailApi,
        queryStringAddOn: ' in:spam ',
        addToListMethod: addToHomeScreenList,
        removeFromListMethod: removeFromHomeScreenList,
      ),

      MailDisplayList(
        key: const Key('BIN'),
        gmailApi: widget.gmailApi,
        queryStringAddOn: ' in:bin ',
        addToListMethod: addToHomeScreenList,
        removeFromListMethod: removeFromHomeScreenList,
      ),
    ];

    init();
    currentDisplayScreen = homeScreenTabsList[0];
  }

  Future<void> init() async {
    Utils.username = await OAuthClient.getCurrentUserNameFromApi(widget.gmailApi);
  }

  Future<void> addToHomeScreenList(
      {required String listName, required EmailMessage msg}) async {
    for (HomeScreenList homeScreenTab in homeScreenTabsList as List<HomeScreenList>) {
      if (homeScreenTab.key.toString() == listName) {
        // the correct list is found, adding the element to the top of the list
        homeScreenTab.addElementToTop(msg);
      }
    }
  }

  Future<void> removeFromHomeScreenList(
      {required String listName, required String msgId}) async {
    for (HomeScreenList homeScreenTab in homeScreenTabsList as List<HomeScreenList> ) {
      if (homeScreenTab.key.toString() == listName) {
        // the correct list is found, removing the element from the list
        homeScreenTab.removeElement(msgId);
      }
    }
  }

  void setNewScreen( int index ) {
    setState(() {
      selectedDrawer = index;
      currentDisplayScreen = homeScreenTabsList[index];
      mainScreen = currentDisplayScreen;
      firstTimeSearchTriggered = true;
    });

    _scaffoldKey.currentState!.openEndDrawer();
  }

  void showRecommendationScreen() {
    mainScreen ??= currentDisplayScreen;

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

  Color getBackgroundColor(int index) {
    if( selectedDrawer == index ) {
      return const Color.fromRGBO(255, 70, 120, 0.4);
    }

    return Colors.white;
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
        HomeScreenSearchBar(scaffoldKey: _scaffoldKey, triggerSearchScreen: toggleSearchScreen, showSearchRecommendation: showRecommendationScreen,  ),
      ],
    );

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        key: _scaffoldKey,
        onDrawerChanged: (value) {
          if( value ) {
            _controller.forward();
          }
          else {
            _controller.reverse();
          }
        },
        drawer: HomeScreenDrawer(
          notifyParent: setNewScreen,
          displayScreen: currentDisplayScreen,
          displayOptions: homeScreenTabsList,
          getBackgroundColor: getBackgroundColor,
        ),
        appBar: _appBar,
        body: SizedBox(
          height: MediaQuery.of(context).size.height - widget.topPadding - widget.bottomPadding,
          child: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height - _appBar.preferredSize.height - widget.topPadding - widget.bottomPadding - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom - 10,
                child: Transform.translate(
                    offset: Offset( _animation.value, 0.0),
                    child: currentDisplayScreen
                ),
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
