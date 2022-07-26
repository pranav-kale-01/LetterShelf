import 'package:flutter/material.dart';
import 'package:letter_shelf/widgets/bottom_popup_dialog.dart';

class LabelsBottomDialog extends StatefulWidget {
  final double topPadding;
  Map<String,dynamic> labels;
  final Map<String,IconData> labelIcons;

  LabelsBottomDialog({
    Key? key,
    required this.topPadding,
    required this.labels,
    required this.labelIcons,
  }) : super(key: key);

  @override
  _LabelsBottomDialogState createState() => _LabelsBottomDialogState();
}

class _LabelsBottomDialogState extends State<LabelsBottomDialog> {
  @override
  Widget build(BuildContext context) {
    return BottomPopupDialog(
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
                children: widget.labels.keys.map((e) {
                  return Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0,),
                        child: Icon(
                          widget.labelIcons[e],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text( e[0].toUpperCase() + e.substring(1) ),
                      ),
                      Expanded(
                        child: Container(
                          alignment: Alignment.centerRight,
                          child: Checkbox(
                            value: widget.labels[e],
                            onChanged: (value) {
                              setState(() {
                                widget.labels[e] = value;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
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

