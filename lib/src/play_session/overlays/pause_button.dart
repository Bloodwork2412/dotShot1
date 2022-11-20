import 'package:dot_shot/src/play_session/level_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../style/palette.dart';

// pause button in corner of screen in round
class PauseButton extends StatelessWidget {
  static const String id = 'pauseButton';
  DotShotGame gameRef;
  PauseButton({Key? key, required this.gameRef}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('creating pause button');
    return Align(
        alignment: Alignment.topRight,
        child: TextButton(
          child: (Icon(Icons.pause_circle_outline, color: Palette().lightgray, size: 50)),
          onPressed: () {
            print("pressed pause");
            gameRef.pauseGame();
          },
        ));
  }
}
