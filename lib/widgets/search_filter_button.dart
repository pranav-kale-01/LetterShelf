import 'package:flutter/material.dart';

class SearchFilterButton extends StatefulWidget {
  final String label;
  final bool showDropDownIcon;

  const SearchFilterButton({
    Key? key,
    required this.label,
    this.showDropDownIcon = true,
  }) : super(key: key);

  @override
  _SearchFilterButtonState createState() => _SearchFilterButtonState();
}

class _SearchFilterButtonState extends State<SearchFilterButton> {
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
        onTap: () {},
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          margin: const EdgeInsets.all(1.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0 ),
            child: Row(
              children: [
                Text(
                  widget.label,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600
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
      ),
    );
  }
}