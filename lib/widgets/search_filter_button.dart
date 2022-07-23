import 'package:flutter/material.dart';

class SearchFilterButton extends StatefulWidget {
  static const int pushButton = 0;
  static const int toggleButton = 1;

  final String label;
  final bool showDropDownIcon;
  final int behaviour;
  final Function(String) onTap;

  const SearchFilterButton({
    Key? key,
    required this.label,
    this.showDropDownIcon = true,
    this.behaviour = SearchFilterButton.pushButton,
    required this.onTap,
  }) : super(key: key);

  @override
  _SearchFilterButtonState createState() => _SearchFilterButtonState();
}

class _SearchFilterButtonState extends State<SearchFilterButton> {
  // used only if SearchFilterButton.behaviour is SearchFilterButton.toggleButton
  bool _toggleState = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xFFC7C7C7),
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.symmetric( horizontal: 8.0, ),
      child: InkWell(
        splashColor: const Color(0xFFC7C7C7),
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          if( widget.behaviour == SearchFilterButton.toggleButton ) {
            setState(() {
              _toggleState = !_toggleState;
            });
          }


          // calling the user defined function
          widget.onTap(widget.label);
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: _toggleState ? const Color(0xFFC3E7FF) : Colors.white,
          ),
          margin: _toggleState ? const EdgeInsets.all(0.0) : const EdgeInsets.all(1.0),
          padding: _toggleState ? const EdgeInsets.all(1.0) : const EdgeInsets.all(0.0),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0 ),
                child: Text(
                  widget.label,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600
                  ),
                ),
              ),
              if( widget.showDropDownIcon )
                const Icon(
                  Icons.arrow_drop_down_sharp
                ),
            ],
          ),
        ),
      ),
    );
  }
}