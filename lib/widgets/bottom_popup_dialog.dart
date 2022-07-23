import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

class BottomPopupDialog extends StatefulWidget {
  /// represents the maximum height of the widget before it tries to become fullscreen (must be in range 0.0 - 1.0)
  final double maxFloatingHeight;
  Widget? child;

  /// sets the child
  void setChild() {

  }

  BottomPopupDialog({
    Key? key,
    this.child,
    this.maxFloatingHeight = 0.6
  }) : super(key: key);

  @override
  _BottomPopupDialogState createState() => _BottomPopupDialogState();
}

class _BottomPopupDialogState extends State<BottomPopupDialog> {
  ScrollController scrollController = ScrollController(initialScrollOffset: 1);
  ScrollController innerScrollController = ScrollController();
  Radius bottomDialogBorderRadius = const Radius.circular(15);
  bool positionNotZero = true;

  double? screenHeight;
  bool isNeverScrollableScrollPhysics = false;
  ScrollPhysics? innerScrollPhysics = const NeverScrollableScrollPhysics();
  ScrollPosition? scrollPosition;

  bool isAnimating = false;

  @override
  Widget build(BuildContext context) {
    // adding listener to scroll Controller
    scrollController.addListener(() async {
      // breaking the operation if the the scroll view is currently animating
      if( isAnimating ) {
        return;
      }

      scrollPosition ??= scrollController.positions.toList()[0];
      screenHeight ??= MediaQuery.of(context).size.height;

      // checking scroll direction
      if( scrollController.position.userScrollDirection == ScrollDirection.forward) {
        // if the bottom sheet is at the lowest position and user scrolls down, then the bottom sheet will animate down and then close
        if( scrollController.position.pixels == 0.0 ) {
          try {
            isAnimating = true;

            SchedulerBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pop();
            });
          }
          catch( e ) {
            debugPrint( e.toString());
          }
          return;
        }
        else {
          isAnimating = true;

          await scrollController.animateTo(
            1.0,
            curve: Curves.linear,
            duration: const Duration( milliseconds: 250 ),
          ).then( (_) {
            isAnimating = false;
          });
        }
      }
      else if(  scrollController.position.userScrollDirection == ScrollDirection.reverse  ) {
        // if the bottom sheet is at the the bottom and user scrolls upwards then, animating up till the bottom sheet covers the whole page
        isAnimating = true;

        await scrollController.animateTo(
          screenHeight! * widget.maxFloatingHeight,
          curve: Curves.linear,
          duration: const Duration( milliseconds: 250 ),
        ).then( (_) {
          isAnimating = false;
        });
      }

      // if the bottom sheet covers up the whole screen, then we will replace the circular border with sharp borders
      if( scrollController.position.pixels == scrollController.position.maxScrollExtent && ( screenHeight! * widget.maxFloatingHeight ).round() == scrollPosition!.maxScrollExtent.round() ) {

        positionNotZero = true;
        innerScrollController.jumpTo( 1.0 );

        isNeverScrollableScrollPhysics = true;
        innerScrollPhysics = const ClampingScrollPhysics();

        setState(() {
          bottomDialogBorderRadius = Radius.zero;
        });
      }
      else if(positionNotZero){
        positionNotZero = false;

        isNeverScrollableScrollPhysics = false;
        innerScrollPhysics = const NeverScrollableScrollPhysics();

        setState(() {
          bottomDialogBorderRadius = const Radius.circular(15);
        });
      }
    });

    if( innerScrollController.hasClients ) {
      // scroll Controller for inner SingleChildScrollView
      innerScrollController.addListener(() async {
        scrollPosition ??= scrollController.positions.toList()[0];
        screenHeight ??= MediaQuery.of(context).size.height;

        if( innerScrollController.offset == 0.0 ) {
          await scrollController.animateTo(
            (scrollPosition!.maxScrollExtent.round() - screenHeight! * widget.maxFloatingHeight) + 1,
            duration: const Duration( milliseconds: 250),
            curve: Curves.linear,
          );
        }
      });
    }

    var topPadding =MediaQueryData.fromWindow(window).padding.top;

    return Dialog(
        insetPadding: EdgeInsets.zero,
        alignment: Alignment.bottomCenter,
        backgroundColor: Colors.transparent,
        elevation: 0,

        child: SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: NotificationListener<OverscrollIndicatorNotification>(
              onNotification: (OverscrollIndicatorNotification overScroll) {
                overScroll.disallowIndicator();
                return false;
              },
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: ( ) => Navigator.of(context).pop(),
                      child: Container(
                        height: MediaQuery.of(context).size.height * widget.maxFloatingHeight,
                        color: Colors.transparent,
                      ),
                    ),
                    Container(
                      constraints: BoxConstraints(
                        minHeight: ( MediaQuery.of(context).size.height * (1.0 - widget.maxFloatingHeight) - topPadding ) + 1,
                      ),
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height - topPadding,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.vertical(
                            top: bottomDialogBorderRadius,
                          ),
                          color: Colors.white,
                        ),
                        child: Container(
                          margin: const EdgeInsets.only(top: 10.0),
                          child: NotificationListener<OverscrollIndicatorNotification>(
                            onNotification: (OverscrollIndicatorNotification overScroll) {
                              overScroll.disallowIndicator();
                              return false;
                            },
                            child: SingleChildScrollView(
                              physics: innerScrollPhysics,
                              controller: innerScrollController,
                              child: widget.child,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
        )
    );
  }
}
