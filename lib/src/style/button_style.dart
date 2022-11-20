import 'dart:ui';

import 'package:dot_shot/src/style/palette.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// basic button theme used for all buttons
class MyButton extends StatelessWidget {
  final String text; // main text
  String subText; // small text below main text (only on menu screen)
  Color buttonColor = Palette().lightgray;
  Color backgroundColor = Palette().background;

  final Function() onPressed; // what happens when button is pressed

  MyButton({
    required this.text,
    this.subText = '',
    Color newColor = Colors.transparent,
    Color newBackground = Colors.transparent,
    required this.onPressed,
  }) {
    if (newColor != Colors.transparent) {
      buttonColor = newColor;
    }
    if (newBackground != Colors.transparent) {
      backgroundColor = newBackground;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(child: Container()),
      Expanded(
          flex: 6,
          child: ClipRRect(
              borderRadius: BorderRadius.circular(64),
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                    backgroundColor: MaterialStateColor.resolveWith((states) => backgroundColor),
                    side: BorderSide(color: buttonColor, width: 7),
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(64)))),
                onPressed: onPressed,
                child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(children: [
                      // subtext only shown if a subtext was passed
                      Text(text,
                          style: TextStyle(
                            color: buttonColor,
                            fontSize: 32.0,
                          )),
                      subText == ''
                          ? Container()
                          : Text(subText, style: TextStyle(color: buttonColor, fontSize: 20.0))
                    ])),
              ))),
      Expanded(child: Container())
    ]);
  }
}
