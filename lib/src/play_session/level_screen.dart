// import 'package:baloon_popper/manager/balloon_manager.dart';
import 'dart:math';

import 'package:dot_shot/src/game_objects/balls.dart';
import 'package:dot_shot/src/player_progress/local_storage_player_progress_persistence.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../game_objects/arrow.dart';
import '../game_objects/line.dart';
import '../level_selection/levels.dart';
import '../style/palette.dart';
import 'overlays/game_over_menu.dart';
import 'overlays/pause_button.dart';
import 'overlays/pause_menu.dart';

// ignore: deprecated_member_use
class DotShotGame extends FlameGame with HasCollisionDetection, TapDetector {
  final GameLevel level;
  late Sprite arrSprite;

  late final Line line;
  late TimeLine timeLine;
  late final Arrow arrow;
  late List<FlyingArrow> flyArrows =
      <FlyingArrow>[]; // FlyingArrow as list since several can be flying at the same time
  late TripleArrow tripleArrow1;
  late TripleArrow tripleArrow2;
  late final Circle circle;

  late TextComponent scoreBox; // Text showing score and arrow amount
  late TextComponent arrowsBox;
  late TextComponent watermark;
  late ColorEffect arrowsBoxColor;

  final List<Ball> balls = <Ball>[];
  Stopwatch watch = Stopwatch();
  Stopwatch interval = Stopwatch();

  // colors used as ball colors
  final List<Color> colors = <Color>[Palette().color1, Palette().color2, Palette().color3];
  final List<double> powerUps = <double>[
    10, // 0 = arrow and balls lightgray
    10, // 1 = slow-mo
    13, // 2 = triple arrows
    10 // 3 = unlimited Arrows // reflective Arrow
  ];

  double spawnFreq = 0; // time between two balls spawning
  int score = 0; // current score
  int arrows = 10; // current amount of arrows
  int arrColor = 0; // current arrow color (index of colors list)
  int powerUpTime = 0; // number of ms until a new ball gets a powerUp
  int currentPowerUp = 99; // powerUp currently running
  int lastPU = 99; // PowerUp that was last used
  bool forceBallColor =
      true; // true if arrow receives a new color before a ball is on the field => new ball will have the color of the arrow
  bool checkedHits =
      false; // checks if prediction of which balls will be hit was accurate and if wrong arrow color was chosen therefore
  double lineYPos = 0; // y axis pos of bottom line

  @override
  Color backgroundColor() => Colors.transparent;

  // Constructor
  DotShotGame(this.level);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    print("loading LevelScreen");

    // to see gameOverScreen in Level 2
    /*
    if (level.number == 2) {
      arrows = 0;
    }
     */

    // draws the line above the arrow
    arrColor = Random().nextInt(colors.length);
    powerUpTime = (10 + Random().nextInt(10)) * 1000;
    // powerUpTime = 0; // to immediately get a powerUp

    lineYPos = size.y / 4 * 3;
    line = Line(lineYPos);
    add(line);
    timeLine =
        TimeLine(99, lineYPos, size.x, line.rectHeight); // only necessary because needs to be initialized

    arrow = Arrow(await loadSprite('arrow.png'), level, colors[arrColor]);
    arrSprite = await loadSprite('arrow.png');
    circle = Circle(colors[arrColor]);
    add(arrow);
    add(circle);
    tripleArrow1 = TripleArrow(arrow, true);
    tripleArrow2 = TripleArrow(arrow, false);

    addTextWidgets(lineYPos);
    addStartBalls(); // balls already on playing field when round starts

    watch.start();
    interval.start();
    print("loaded Background");
  }

  // when screen is tapped
  @override
  void onTap() {
    // shoot an arrow if there are any left
    if (arrows > 0) {
      Color oldArrColor = colors[arrColor];
      findArrowColor();
      if (currentPowerUp != 3) {
        arrows--;
        if (arrows < 0) {
          arrows = 0;
        }
        arrowsBox.text = (arrows.toString());
      }
      Color flyArrowColor = colors[arrColor];

      if (currentPowerUp == 0) {
        // print('arrow color to light gray');
        flyArrowColor = Palette().lightgray;
        oldArrColor = Palette().lightgray;
      }
      FlyingArrow flyArrow =
          FlyingArrow(arrSprite, oldArrColor, arrow.angle, watch.elapsedMilliseconds, level);
      flyArrows.add(flyArrow);
      add(flyArrow);
      arrow.shrinkArrow();
      changeArrowColorTo(flyArrowColor);

      if (currentPowerUp == 2) {
        FlyingArrow flyArrow1 =
            FlyingArrow(arrSprite, oldArrColor, tripleArrow1.angle, watch.elapsedMilliseconds, level);
        flyArrows.add(flyArrow1);
        add(flyArrow1);
        FlyingArrow flyArrow2 =
            FlyingArrow(arrSprite, oldArrColor, tripleArrow2.angle, watch.elapsedMilliseconds, level);
        flyArrows.add(flyArrow2);
        add(flyArrow2);
        tripleArrow1.shrinkArrow();
        tripleArrow2.shrinkArrow();
      }

      // will have to check if predicted hits were correct
      checkedHits = false;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    // remove all balls that have shouldRemove == true
    removeBalls();
    // add new Ball to List and screen
    addBalls();

    // if no arrows left and no arrow flying anymore
    if (arrows <= 0 && flyArrows.length == 0) {
      // print('stop round');
      gameOver();
    }

    // checks if arrow has right color after it was fired
    checkArrowColor();

    if (currentPowerUp < powerUps.length && timeLine.efController.completed) {
      stopPowerUp();
    }
    // remove FlyArrows that have finished their flight
    removeFlyArrows();
  }

  // when app is opened, closed or in background
  @override
  void lifecycleStateChange(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // print('resumed');
    } else {
      if (!overlays.isActive(GameOverMenu.id)) {
        pauseGame();
        // print('stopped');
      }
    }
  }

  void resumeGame() {
    watch.start();
    interval.start();
    arrow.resumeGame();
    for (Ball x in balls) {
      x.resumeGame();
    }
  }

  void pauseGame() {
    // print('paused Game');
    watch.stop();
    interval.stop();
    arrow.pauseGame();
    for (Ball x in balls) {
      x.pauseGame();
    }
    pauseEngine();
    overlays.add(PauseMenu.id);
    overlays.remove(PauseButton.id);
  }

  void gameOver() {
    pauseEngine();
    overlays.remove(PauseButton.id);
    overlays.add(GameOverMenu.id);
  }

  // remove all balls that need to be removed
  void removeBalls() {
    List<Ball> toRemove = [];
    for (Ball x in balls) {
      if (x.removeBall()) {
        remove(x);
        toRemove.add(x);
        // print('removing ball from list');

        // if player gets a point from that ball
        if (x.getPoint) {
          arrows = arrows + x.value;
          score++;
        } else {
          arrows = arrows - x.value;
          line.errorColor();
          if (timeLine.isMounted) {
            timeLine.errorColor();
          }
        }
        if (arrows < 0) {
          arrows = 0;
        }
        if (currentPowerUp != 3) {
          arrowsBox.text = (arrows.toString());
        }
        scoreBox.text = (score.toString());

        ScaleEffect arrowsBoxEf = ScaleEffect.by(Vector2.all(1.4),
            SequenceEffectController([LinearEffectController(0.15), ReverseLinearEffectController((0.15))]));
        arrowsBox.add(arrowsBoxEf);
      }
    }
    balls.removeWhere((e) => toRemove.contains(e));
  }

  // adds a new ball when certain amount of time has passed
  void addBalls() {
    if (interval.elapsedMilliseconds > spawnFreq) {
      Ball ball = Ball(level, watch.elapsedMilliseconds, colors, getBallColor(), powerUp(), 99);
      ball.priority = 2;
      balls.add(ball);
      add(ball);

      if (currentPowerUp == 0) {
        ball.setColorLightGray(true);
      }
      if (currentPowerUp == 1) {
        ball.setHalfSpeed(true);
      }
      // amount of time until next ball will be spawned
      spawnFreq = getSpawnDistance() / ball.getBallSpeed(1) * 1000;
      interval.reset();
    }
  }

  // three balls already of playing field at the start of the round
  void addStartBalls() {
    for (int i = 0; i < 3; i++) {
      Ball ball = Ball(level, watch.elapsedMilliseconds, colors, getBallColor(), powerUp(), i);
      ball.priority = 2;
      balls.add(ball);
      add(ball);
    }
  }

  // distance between the center of two balls
  double getSpawnDistance() {
    double time = watch.elapsedMilliseconds / 1000;
    double spawnDistance = (2 + (level.spawn / (1 + (time) / level.spawnInc))) * size.x * level.ballSize;
    return spawnDistance;
  }

  // remove all FlyingArrows that have completed their flights
  void removeFlyArrows() {
    List<FlyingArrow> toRemove = [];
    for (FlyingArrow x in flyArrows) {
      if (!x.isFlying()) {
        remove(x);
        toRemove.add(x);
        // print('removing ball from list');
      }
    }
    flyArrows.removeWhere((e) => toRemove.contains(e));
  }

  // checks if arrow color is correct (lvl 1: arrows always same color as lowest ball, lvl 2+3: arrow has color of 1 lowest 2 balls)
  void checkArrowColor() {
    if (!checkedHits && flyArrows.length <= 0) {
      checkedHits = true;
      // if arrow is not color of first or second ball (depending on level.number)
      if (balls.length > 0 &&
          ((level.number == 1 && arrColor != balls[0].ballColor) ||
              (level.number > 1 &&
                  arrColor != balls[0].ballColor &&
                  (balls.length < 2 || (balls.length >= 2 && arrColor != balls[1].ballColor))))) {
        if (currentPowerUp == 0) {
          changeArrowColorTo(Palette().lightgray);
        } else {
          changeArrowColorTo(colors[balls[0].ballColor]);
        }
        arrColor = balls[0].ballColor;
        // print('changed color of arrow');
      }
    }
  }

  // changes color of arrows and all other necessary objects
  void changeArrowColorTo(Color color) {
    arrow.changeColor(color);
    circle.changeColor(color);
    if (currentPowerUp == 2) {
      tripleArrow1.changeColor();
      tripleArrow2.changeColor();
    }
    if (currentPowerUp == 3) {
      arrowsBox.textRenderer = TextPaint(style: TextStyle(color: color, fontSize: 60));
    }
  }

  // calculates what the next arrow color should be according to the flight path of this FlyingArrow
  void findArrowColor() {
    arrColor = Random().nextInt(colors.length);
    List<Ball> ballsLater = ballsAfterHit(arrow.color);
    // print('angle: $arrowAngleDegrees');
    if ((level.number == 1 && ballsLater.length >= 1) ||
        ballsLater.length == 1 ||
        (ballsLater.length >= 1 && ballsLater[0].position.y > size.y * 0.4)) {
      // print('forced Color');
      arrColor = ballsLater[0].ballColor;
    } else if (ballsLater.length >= 2) {
      arrColor = ballsLater[Random().nextInt(2)].ballColor;
    } else {
      // print('forcing ballColor');
      forceBallColor = true;
    }
  }

  // all textfields will be added
  void addTextWidgets(double lineHeight) {
    TextComponent scoreText = TextComponent(anchor: Anchor.topRight, text: ('Points'), priority: 3);
    scoreText
      ..position = Vector2(size.x * 0.96, lineHeight + size.y * 0.01)
      ..textRenderer = TextPaint(style: TextStyle(color: Palette().lightgray, fontSize: 25));
    add(scoreText);

    scoreBox = TextComponent(anchor: Anchor.topCenter, text: (score.toString()), priority: 3);
    scoreBox
      ..position = Vector2(scoreText.x - scoreText.width / 2, scoreText.y + scoreText.height * 1.01)
      ..textRenderer = TextPaint(style: TextStyle(color: Palette().lightgray, fontSize: 40));
    add(scoreBox);

    TextComponent arrowText = TextComponent(anchor: Anchor.topLeft, text: ('Arrows'), priority: 3);
    arrowText
      ..position = Vector2(size.x * 0.04, lineHeight + size.y * 0.01)
      ..textRenderer = TextPaint(style: TextStyle(color: Palette().lightgray, fontSize: 25));
    add(arrowText);

    arrowsBox = TextComponent(anchor: Anchor.topCenter, text: (arrows.toString()), priority: 3);
    arrowsBox
      ..position = Vector2(arrowText.x + arrowText.width / 2, arrowText.y + arrowText.height * 1.01)
      ..textRenderer = TextPaint(
          style:
              TextStyle(color: Palette().lightgray, fontSize: 40)); // also change fontSize in PowerUp case 3!
    add(arrowsBox);

    watermark = TextComponent(
      anchor: Anchor.center,
      text: ('Dot\nShot'),
      priority: 1,
    );
    // add(watermark);
  }

  // selects which powerUp a ball should have
  int powerUp() {
    if (powerUpTime < watch.elapsedMilliseconds) {
      // return Random().nextInt(powerUps.length);
      int powerUpNum = powerUps.length;
      // randomly selects a power up. If less than 30 secs have passed, the slow mo power up will not be selected
      while (powerUpNum >= powerUps.length ||
          (powerUpTime < 30 * 1000 && powerUpNum == 1) ||
          powerUpNum == lastPU) {
        powerUpNum = Random().nextInt(powerUps.length);
      }
      powerUpTime =
          (watch.elapsedMilliseconds + (powerUps[powerUpNum] + 10 + Random().nextInt(15)) * 1000).toInt();
      return powerUpNum;
    } else {
      return powerUps.length;
    }
  }

  // called when a ball with a powerUp is hit
  void startPowerUp(int powerNum) {
    print('start powerUP $powerNum');
    currentPowerUp = powerNum;
    lastPU = powerNum;
    timeLine = TimeLine(powerUps[powerNum], lineYPos, size.x, line.rectHeight);
    add(timeLine);

    switch (powerNum) {
      case 0:
        for (Ball x in balls) {
          x.setColorLightGray(true);
        }
        arrow.setColorLightGray(true);
        circle.setColorLightGray(true);
        changeArrowColorTo(Palette().lightgray);
        break;

      case 1:
        for (Ball x in balls) {
          x.setHalfSpeed(true);
        }
        arrow.setHalfSpeed(true);
        break;

      case 2:
        tripleArrow1 = TripleArrow(arrow, true);
        add(tripleArrow1);
        tripleArrow2 = TripleArrow(arrow, false);
        add(tripleArrow2);
        arrow.setPowerUp2(true);
        break;

      case 3:
        arrowsBox
          ..text = '∞'
          ..textRenderer = TextPaint(style: TextStyle(color: arrow.color, fontSize: 60));
        print('arrowsBox.text = ${arrowsBox.text}');
        break;

      default:
        break;
    }
  }

  // called when a powerUp ends
  void stopPowerUp() {
    print('stop powerUP $currentPowerUp');
    remove(timeLine);
    switch (currentPowerUp) {
      case 0:
        for (Ball x in balls) {
          x.setColorLightGray(false);
        }
        arrow.setColorLightGray(false);
        circle.setColorLightGray(false);
        changeArrowColorTo(colors[arrColor]);
        break;

      case 1:
        for (Ball x in balls) {
          x.setHalfSpeed(false);
        }
        arrow.setHalfSpeed(false);
        break;

      case 2:
        remove(tripleArrow1);
        remove(tripleArrow2);
        arrow.setPowerUp2(false);
        break;

      case 3:
        arrowsBox
          ..text = arrows.toString()
          ..textRenderer = TextPaint(style: TextStyle(color: Palette().lightgray, fontSize: 40));
        break;

      default:
        break;
    }
    currentPowerUp = powerUps.length;
  }

  // selects color of the next ball
  int getBallColor() {
    // arrow color already determines color of the net ball
    if (forceBallColor) {
      forceBallColor = false;
      return arrColor;
    }
    int rand = Random().nextInt(3);

    if (balls.length >= 2 &&
        balls[balls.length - 1].ballColor == balls[balls.length - 2].ballColor &&
        balls[balls.length - 1].ballColor == rand) {
      int newRand = Random().nextInt(3);
      while (newRand - rand == 0) {
        newRand = Random().nextInt(3);
      }
      rand = newRand;
      // print('changed color to $rand');
    }
    return rand;
  }

  // predicts which balls the current FlyingArrows will hit in order to determine what color the next arrow should have
  List<Ball> ballsAfterHit(Color arrColor) {
    List<Ball> ballsCopy = balls.toList(); // creates growable copy of list
    List<double> angles = <double>[arrow.angle]; // list of angles in which arrows are currently flying in

    // if there are 3 arrows, check all of their future hits
    if (currentPowerUp == 2) {
      angles.add(tripleArrow1.angle);
      angles.add(tripleArrow2.angle);
    }

    // checks potential hits of each angle
    for (int i = 0; i < angles.length; i++) {
      double arrowAngleDegrees = degrees(angles[i]); // angle > 0
      if (arrowAngleDegrees <= 0) {
        arrowAngleDegrees = -90 - arrowAngleDegrees;
      } else if (arrowAngleDegrees > 0) {
        arrowAngleDegrees = 90 - arrowAngleDegrees;
      }
      double arrowAngle = radians(arrowAngleDegrees);

      for (int i = 0; i < ballsCopy.length; i++) {
        // checks all Balls that have the same color as the flying arrow
        if (arrColor == colors[ballsCopy[i].ballColor]) {
          double angleDeg = degrees(arrowAngle);
          double ballW = ((arrow.position.y - ballsCopy[i].position.y) * sin(pi / 2 - arrowAngle)) /
              sin(arrowAngle); // distance from center of ball to arrow?
          double arrW = ((arrow.width * sin(90)) / sin(arrowAngle)) / 2; // diagonal arrow width
          double xDiff = ballsCopy[i].position.x - arrow.position.x;
          double radius = ballsCopy[i].radius;

          if ((xDiff > 0 && angleDeg < 0) || (xDiff < 0 && angleDeg > 0)) {
            // if arrow does not point to side of ball, switch arrW
            arrW = -arrW;
          }

          // if the horizontal diameter of the arrow following along a line at the specified angle touches the outlines of the ball
          if (((xDiff <= 0) && (-radius + arrW < xDiff - ballW) && (radius - arrW > xDiff - ballW)) ||
              ((xDiff > 0) && (-radius - arrW < xDiff - ballW) && (radius + arrW > xDiff - ballW))) {
            // print('hit ball $i');
            // ball will be removed from ballsCopy list
            ballsCopy.removeAt(i);
            i--;
          }
        }
      }
    }
    return ballsCopy;
  }

  // if current score is a highscore
  Future<bool> isHighscore() async {
    LocalStoragePlayerProgressPersistence pers = LocalStoragePlayerProgressPersistence();
    int highScore = await pers.getHighscore(level.number);
    if (score > highScore) {
      // print('saved Highscore of $score');
      pers.saveHighscore(level.number, score);
      return true;
    } else {
      return false;
    }
  }
}
