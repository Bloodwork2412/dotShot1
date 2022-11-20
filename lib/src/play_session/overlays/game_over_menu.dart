import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../style/button_style.dart';
import '../../style/palette.dart';
import '../level_screen.dart';

// Menu that is shown when a round ended
class GameOverMenu extends StatefulWidget {
  static const String id = 'gameOverMenu';
  final DotShotGame gameRef;

  const GameOverMenu({super.key, required this.gameRef});

  @override
  State<GameOverMenu> createState() => GameOverState(key: key, gameRef: gameRef);
}

class GameOverState extends State<GameOverMenu> with TickerProviderStateMixin {
  DotShotGame gameRef;
  Color textColor = Palette().lightgray;
  late AnimationController ac;
  late Timer timer;
  int animationDuration = 300;
  int counter = 0;
  int score = 0;
  int showEachNumber = 0;

  GameOverState({Key? key, required this.gameRef}) {
    score = gameRef.score;
    // amount of time the score counter shows each value
    showEachNumber = (400000 / (score + 1)).round();
    // print('show each number for $showEachNumber ms');

    setCounter();
  }

  @override
  Widget build(BuildContext context) {
    Color arrowColor = gameRef.arrow.color;
    String scoreText = 'SCORE';
    String highScoreText = 'NEW HIGHSCORE';
    // textColor = arrowColor;
    // print('starting game over menu');
    ac = AnimationController(
      duration: Duration(milliseconds: animationDuration),
      vsync: this,
    );

    return Scaffold(
      backgroundColor: Palette().overlayBg,
      body: FadeTransition(
          opacity: CurvedAnimation(parent: ac..forward(), curve: Curves.easeIn),
          child: Center(
              child: Padding(
                  padding: EdgeInsets.all(20),
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(32),
                      child: Container(
                          color: Palette().lightgray,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ClipPath(
                                  clipper: OvalClipper(),
                                  child: Container(
                                      color: arrowColor,
                                      child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Column(children: [
                                              SizedBox(
                                                height: 16,
                                              ),
                                              FutureBuilder<bool>(
                                                  future: gameRef.isHighscore(),
                                                  builder: (context, AsyncSnapshot snapshot) {
                                                    if (!snapshot.hasData) {
                                                      return Text(scoreText,
                                                          style: TextStyle(
                                                            fontSize: 40.0,
                                                            fontWeight: FontWeight.bold,
                                                            color: textColor,
                                                          ));
                                                    } else {
                                                      return Text(snapshot.data ? highScoreText : scoreText,
                                                          style: TextStyle(
                                                            fontSize: 40.0,
                                                            fontWeight: FontWeight.bold,
                                                            color: textColor,
                                                          ));
                                                    }
                                                  }),
                                              Text(
                                                '$counter',
                                                style: TextStyle(
                                                  fontSize: 60.0,
                                                  fontWeight: FontWeight.bold,
                                                  color: textColor,
                                                ),
                                              ),
                                              SizedBox(height: 6)
                                            ])
                                          ]))),
                              SizedBox(
                                height: 24,
                              ),
                              MyButton(
                                text: 'HOME',
                                newColor: Palette().background,
                                newBackground: Palette().lightgray,
                                onPressed: () {
                                  goHome(context);
                                },
                              ),
                              SizedBox(
                                height: 24,
                              ),
                              MyButton(
                                  text: 'SHARE',
                                  newColor: Palette().background,
                                  newBackground: Palette().lightgray,
                                  onPressed: () {}),
                              SizedBox(
                                height: 24,
                              ),
                            ],
                          )))))),
    );
  }

  @override
  dispose() {
    ac.dispose(); // you need this
    super.dispose();
  }

  // go back to main menu
  void goHome(BuildContext context) {
    gameRef.overlays.remove(GameOverMenu.id);
    gameRef.resumeEngine();
    Navigator.of(context).pop();
  }

  // recursive for each value shown in score counter
  void setCounter() {
    timer = new Timer(Duration(microseconds: showEachNumber), () {
      setState(() {
        animationDuration = 0;
        if (counter < score) {
          counter++;
          // print('score: $score, counter: $counter');
          setCounter();
        }
      });
    });
  }
}

// gives game over menu its oval edge
class OvalClipper extends CustomClipper<Path> {
  @override
  getClip(Size size) {
    double width = size.width;
    double height = size.height;
    double offset = 50;
    Path path = Path();
    path.lineTo(0, height - offset);
    path.quadraticBezierTo(width / 2, height + offset, width, height - offset);
    path.lineTo(width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}
