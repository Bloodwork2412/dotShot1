import 'dart:math';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../style/palette.dart';
import 'menu_balls.dart';

// background with balls on main screen with level selection
// not relevant to game, slightly different ball pattern
// ignore: deprecated_member_use
class MainBackground extends FlameGame {
  final List<Color> colors = <Color>[
    Palette().color1,
    Palette().color2,
    Palette().color3
  ];
  List<MenuBall> balls = <MenuBall>[];
  Stopwatch watch = Stopwatch();
  int spawnTime = 0;
  int spawnIntervall = 2500;
  int spawnRand = 400;
  int ballSpeed = 25;
  bool addingBalls = false;

  MainBackground() {}

  @override
  Color backgroundColor() => Palette().background;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    watch.start();
    print('loading MainBackground');
    addBalls();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    if (spawnTime == 0) {
      spawnTime = spawnIntervall;
    }
    if (watch.elapsedMilliseconds > spawnTime) {
      // print(watch.elapsedMilliseconds);
      spawnTime = spawnIntervall + Random().nextInt(spawnRand);
      watch.reset();
      MenuBall ball = MenuBall(balls, ballColor(), ballSpeed, size.y * -0.05);
      balls.add(ball);
      add(ball);
    }

    List<MenuBall> toRemove = [];
    for (MenuBall x in balls) {
      if (x.removeBall()) {
        remove(x);
        toRemove.add(x);
        // print('removed Ball from balls');
      }
    }
    balls.removeWhere((e) => toRemove.contains(e));
  }

  // when app is opened, closed or goes into background
  @override
  void lifecycleStateChange(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      watch.start();
      resumeEngine();
      print('resumed');
    } else {
      watch.stop();
      pauseEngine();
      print('stopped');
    }
  }

  // get a ball color that is different from the last ball
  Color ballColor() {
    Color ballColor = colors[Random().nextInt(colors.length)];
    while (balls.length > 1 && ballColor == balls[balls.length - 1].ballColor) {
      ballColor = colors[Random().nextInt(colors.length)];
    }
    return ballColor;
  }

  // add balls that are already on screen when screen is started
  void addBalls() {
    double yPos = size.y;
    for (MenuBall x in balls) {
      remove(x);
    }
    balls.clear();
    // print('yPos: $yPos');
    while (yPos > size.y * -0.05) {
      // print('yPos: $yPos');
      MenuBall ball = MenuBall(balls, ballColor(), ballSpeed, yPos);
      balls.add(ball);
      add(ball);

      yPos = yPos -
          ballSpeed * (spawnIntervall + Random().nextInt(spawnRand)) / 1000;
    }

    watch.reset();
    watch.start();
    // addingBalls = false;
  }
}
