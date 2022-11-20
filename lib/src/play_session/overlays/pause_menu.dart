import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../style/button_style.dart';
import '../../style/palette.dart';
import '../level_screen.dart';
import 'pause_button.dart';

// menu that is shown when round is paused
class PauseMenu extends StatelessWidget {
  static const String id = 'pauseMenu';
  DotShotGame gameRef;

  PauseMenu({Key? key, required this.gameRef}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Palette().overlayBg,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 48,
              ),
              MyButton(
                  text: 'RESUME',
                  // newColor: arrowColor,
                  onPressed: () {
                    startCountdown();
                  }),
              SizedBox(
                height: 32,
              ),
              MyButton(
                text: 'HOME',
                onPressed: () {
                  gameRef.overlays.remove(PauseMenu.id);
                  // gameRef.reset();
                  gameRef.resumeEngine();

                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ));
  }

  void startCountdown() {
    gameRef.overlays.remove(PauseMenu.id);
    gameRef.overlays.add(Countdown.id);
  }
}

// countdown from 3 to 1 before round resumes
class Countdown extends StatefulWidget {
  static const String id = 'countdown';
  final DotShotGame gameRef;

  const Countdown({super.key, required this.gameRef});

  @override
  State<Countdown> createState() => CountdownState(key: key, gameRef: gameRef);
}

class CountdownState extends State<Countdown> with TickerProviderStateMixin {
  DotShotGame gameRef;
  late AnimationController ac;
  int number = 3;
  int intervall = 800; // amount of time each number is shown
  late Timer timer;

  CountdownState({Key? key, required this.gameRef}) {
    setTimer();
  }

  void setTimer() {
    timer = new Timer(Duration(milliseconds: (intervall)), () {
      setState(() {
        number--;
        if (number >= 1) {
          setTimer();
        } else {
          resumeGame();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    ac = AnimationController(
      duration: Duration(milliseconds: (intervall * 0.8).round()),
      vsync: this,
    );

    return Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
            child: ScaleTransition(
                scale: CurvedAnimation(parent: ac..forward(), curve: Curves.easeInOutSine),
                child: Text(
                  number.toString(),
                  style: TextStyle(color: Palette().lightgray, fontSize: 254),
                ))));
  }

  @override
  dispose() {
    ac.dispose(); // you need this
    super.dispose();
  }

  void resumeGame() {
    gameRef.resumeEngine();
    gameRef.resumeGame();
    gameRef.overlays.remove(Countdown.id);
    gameRef.overlays.add(PauseButton.id);
  }
}
