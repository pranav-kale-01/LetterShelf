import 'package:flutter/material.dart';
import 'package:letter_shelf/widgets/bottom_popup_dialog.dart';

class DateFilterBottomDialog extends StatefulWidget {
  final double topPadding;
  String initialDateFilter;
  List<String> dateFilters;
  final Function(String) notifyParent;

  DateFilterBottomDialog({
    Key? key,
    required this.topPadding,
    required this.dateFilters,
    required this.initialDateFilter,
    required this.notifyParent,
  }) : super(key: key);

  @override
  _DateFilterBottomDialogState createState() => _DateFilterBottomDialogState();
}

class _DateFilterBottomDialogState extends State<DateFilterBottomDialog> {
  String? dateFilter;

  @override
  void initState() {
    // setting the preset value to any time
    dateFilter = widget.initialDateFilter;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BottomPopupDialog(
      maxFloatingHeight: 0.55,
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: widget.dateFilters.map((e) {
                  return SizedBox(
                    height: 45,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          widget.notifyParent(e);
                          dateFilter = e;
                        });

                        Navigator.of(context).pop();
                      },
                      child: Container(
                        color: Colors.white,
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6.0),
                              child: Radio(
                                value: e,
                                groupValue: dateFilter,
                                onChanged: (value) { },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6.0),
                              child: Text( e[0].toUpperCase() + e.substring(1) ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                ).toList(),
              ),
            )
          ],
        ),
      ),
    );
  }
}
