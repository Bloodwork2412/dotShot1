import 'dart:async';
import 'dart:math';

import 'package:dot_shot/src/play_session/level_screen.dart';
import 'package:dot_shot/src/style/palette.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';

import '../level_selection/levels.dart';

// circle below the bottom arrow
class Circle extends PositionComponent with HasGameRef<DotShotGame> {
  CircleComponent circle = CircleComponent();
  Color color;
  bool colorLight = false;

  Circle(this.color) {}

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    double height = gameRef.size.y / 6.5;
    double yPos = gameRef.size.y - (height / 2);

    circle
      ..radius = height / 10
      ..setColor(color)
      ..position = Vector2(gameRef.size.x / 2, yPos)
      ..anchor = Anchor.center;
    add(circle);
  }

  void changeColor(Color newColor) {
    color = newColor;
    if (colorLight) {
      newColor = Palette().lightgray;
    }
    circle.setColor(newColor);
  }

  // for power up 0
  void setColorLightGray(bool light) {
    colorLight = light;
  }
}

// this arrow only rotates at the bottom, FlyingArrow (below this class) does the actual flying
class Arrow extends SpriteComponent with HasGameRef<DotShotGame> {
  final debugMode = false; // show outline boxes of arrow
  final GameLevel level; // difficulty chosen
  int rotateDegrees = 90; // angle that arrow rotates
  double duration = 0; // time arrow needs to rotate rotateDegrees to one side
  Stopwatch totalTime = Stopwatch(); // total time of this round
  Stopwatch intervall =
      Stopwatch(); // time since arrow started rotating from angle 0

  late SequenceEffectController rotateEC; // rotate animation
  late LinearEffectController linEC; // makes arrow rotate to the right
  late ReverseLinearEffectController revLinEC; // makes arrow rotate to the left
  late RotateEffect ef; // rotate animation
  late Color color; // current color of arrow

  bool colorLight = false; // powerUp0 active
  bool halfSpeed = false; // powerUp1 active
  bool powerUp2 = false; // powerUp2 active
  bool changedECLeft =
      false; // triple arrow needs to check this during power up 2
  bool changedECRight =
      false; // triple arrow needs to check this during power up 2

  Arrow(Sprite sprite, GameLevel this.level, this.color) {
    this.sprite = sprite;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    double height = gameRef.size.y / 6.5;
    double yPos = gameRef.size.y - (height / 2);
    double width = height / 3;
    // arrow width is height/3

    size = Vector2(width, height);
    position = Vector2(gameRef.size.x / 2, yPos);
    anchor = Anchor.bottomCenter;

    changeColor(color);

    // start stopwatches
    totalTime.start();
    intervall.start();

    // start rotating effect
    updateRotateEC();
    RotateEffect ef0 = RotateEffect.to(
        -pi * (rotateDegrees / 360), EffectController(duration: 0));
    ef = RotateEffect.by(pi * rotateDegrees / 180, rotateEC);
    add(ef0);
    add(ef);
  }

  // executed every few ms
  @override
  void update(double dt) {
    // if arrow made a full rotation
    if (intervall.elapsedMilliseconds / 1000 >= duration * 2) {
      if (powerUp2) {
        changedECLeft = true;
        changedECRight = true;
      }
      intervall.reset();
      // start new rotation
      updateRotateEC();
      ef = RotateEffect.by(pi * rotateDegrees / 180, rotateEC);
      add(ef);
      // print('duration: $duration');
    }
  }

  // duration of one full rotation, decreases as round progresses
  double getDuration() {
    duration = level.arrSpeed /
        (1 + (totalTime.elapsedMilliseconds / 1000) / level.arrInc);
    // if powerUp1
    if (halfSpeed) {
      duration = duration * 2;
    }
    return duration;
  }

  // start new rotation
  void updateRotateEC() {
    duration = getDuration();
    linEC = LinearEffectController(duration);
    revLinEC = ReverseLinearEffectController(duration);
    rotateEC = SequenceEffectController([linEC, revLinEC]);
  }

  // arrow shrinks each time after it was fired, called from level_screen
  void shrinkArrow() {
    // how long will the flying arrow fly
    double flyDuration =
        0.5 / (1 + (totalTime.elapsedMilliseconds / 1000) / level.arrInc);
    SequenceEffectController SEC = SequenceEffectController([
      LinearEffectController(0),
      ReverseLinearEffectController(flyDuration * 0.9)
    ]);
    ScaleEffect efShrink = ScaleEffect.to(Vector2(0.1, 0.1), SEC);
    add(efShrink);
  }

  // when powerUp0 starts or ends
  void setColorLightGray(bool light) {
    colorLight = light;
    if (light) {
      changeColor(Palette().lightgray);
    } else {
      changeColor(color);
    }
  }

  // when powerUp1 starts or ends
  void setHalfSpeed(bool half) {
    halfSpeed = half;
    ef.pause();
    if (half) {
      duration = duration * 2;
    } else {
      duration = duration * 0.5;
    }
    double progress = rotateEC.progress;

    // arrow needs to move at half speed from current position into right direction, compilcated
    if (linEC.progress < 1) {
      // print('going right: $progress \narrDuration: ${duration}');
      linEC = LinearEffectController(duration);
      RotateEffect ef2 = RotateEffect.by(-pi * rotateDegrees / 180, linEC);
      linEC = LinearEffectController((1 - progress) * duration);
      RotateEffect ef1 = RotateEffect.by(
          pi * rotateDegrees / 180 * (1 - progress), linEC, onComplete: () {
        add(ef2); // move to the left end after that
      });
      add(ef1); // move to the right end first
      duration =
          ((2 - progress) * duration + intervall.elapsedMilliseconds / 1000) *
              0.5;
    } else {
      // print('going left: $progress \narrDuration: ${duration}');
      linEC = LinearEffectController(progress * duration);
      RotateEffect ef1 =
          RotateEffect.by(-pi * rotateDegrees / 180 * progress, linEC);
      add(ef1);
      duration =
          (progress * duration + intervall.elapsedMilliseconds / 1000) * 0.5;
    }
    // print('new duration: $duration');
  }

  // when powerUp2 starts or ends
  void setPowerUp2(bool PU2) {
    powerUp2 = PU2;
    if (!powerUp2) {
      changedECRight = false;
      changedECLeft = false;
    }
  }

  void checkedChangeECLeft() {
    changedECLeft = false;
  }

  void checkedChangeECRight() {
    changedECRight = false;
  }

  // change color after arrow was fired
  changeColor(Color newColor) {
    color = newColor;
    // print('light: $colorLight');
    if (colorLight) {
      newColor = Palette().lightgray;
    }
    final colorEf = ColorEffect(
      newColor,
      const Offset(0.0, 1),
      EffectController(duration: 0),
    );
    add(colorEf);
  }

  void pauseGame() {
    totalTime.stop();
    intervall.stop();
  }

  void resumeGame() {
    totalTime.start();
    intervall.start();
  }
}

// arrow that actually flies
class FlyingArrow extends SpriteComponent with HasGameRef<DotShotGame> {
  final debugMode = false;
  GameLevel level;
  late SequenceEffect SEC; // effect controller for arrow to fly
  bool flying = false; // currently flying
  Color color;
  double startFlyTime = 0.5; // time in which arrow completes flight
  double angleArr; // angle of arrow, determines flight path
  int time; // time in round when arrow is shot, determines flight speed

  FlyingArrow(Sprite sprite, this.color, this.angleArr, this.time, this.level) {
    // look of arrow
    this.sprite = sprite;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // in front of balls visually
    priority = 3;
    double height = gameRef.size.y / 6.5;
    double yPos = gameRef.size.y - (height / 2);
    double width = height / 3;
    // width is usually height/3

    size = Vector2(width, height);
    position = Vector2(gameRef.size.x / 2, yPos);
    anchor = Anchor.bottomCenter;

    // hitbox of arrow, diamond shape
    PolygonHitbox hitbox = PolygonHitbox.relative(
      [
        Vector2(0, -1),
        Vector2(-1, -0.45),
        Vector2(-0.15, 1),
        Vector2(0.15, 1),
        Vector2(1, -0.45),
      ],
      position: Vector2(super.width / 2, super.height / 2),
      anchor: Anchor.center,
      parentSize: Vector2(super.width, super.height),
    );
    // passive = can only collide with active objects (only balls)
    hitbox.collisionType = CollisionType.passive;
    add(hitbox);

    // invisible at first
    add(OpacityEffect.to(0, EffectController(duration: 0)));
    fly();
  }

  // makes arrow fly from bottom into desired direction
  void fly() {
    flying = true;
    double flyLength =
        gameRef.size.y * 1.1; // how far it flies, y size of screen * 1.1
    double x = flyLength *
        sin(angleArr) /
        sin(pi / 2); // displacement on x axis depending on angle
    double y = flyLength *
        sin(pi - angleArr - pi / 2) /
        sin(pi / 2); // displacement on y axis depending on angle

    // how long arrow takes to fly path
    double flyDuration = startFlyTime / (1 + (time / 1000) / level.arrInc);
    // effect that creates the movement
    SEC = SequenceEffect([
      RotateEffect.to(angleArr, EffectController(duration: 0)),
      OpacityEffect.to(100, EffectController(duration: 0)),
      MoveEffect.by(Vector2(x, -y), EffectController(duration: flyDuration)),
      OpacityEffect.to(0, EffectController(duration: 0)),
      MoveEffect.to(position, EffectController(duration: 0))
    ], onComplete: () {
      flying = false;
    });
    add(SEC);

    // gives arrow right color
    final colorEf = ColorEffect(
      color,
      const Offset(0.0, 1),
      EffectController(duration: 0),
    );
    add(colorEf);
  }

  bool isFlying() => flying;

  Color getColor() => color;

  void changeColor(Color color2) {
    color = color2;
  }
}

// powerUp2 with three arrow fired simultaneously, is only arrow on either left or right side => called twice for 2 side arrows
class TripleArrow extends SpriteComponent with HasGameRef<DotShotGame> {
  Arrow arrow; // original Arrow
  late SequenceEffectController rotateEC;
  late LinearEffectController linEC; // makes arrow rotate to the right
  late ReverseLinearEffectController revLinEC; // makes arrow rotate to the left
  int offset = 12; // angle offset from original in middle
  bool leftArr; // is left arrow

  TripleArrow(this.arrow, this.leftArr) {}

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    sprite = arrow.sprite;

    double height = gameRef.size.y / 6.5;
    double yPos = gameRef.size.y - (height / 2);
    double width = height / 3;

    // width is usually height/2.3
    size = Vector2(width, height);
    position = Vector2(gameRef.size.x / 2, yPos);
    anchor = Anchor.bottomCenter;

    changeColor();

    // how far the original arrow has travelled so far
    double progress = arrow.rotateEC.progress;
    // current rotation of original arrow
    double arrRotation = (progress * arrow.rotateDegrees / 180 * pi) -
        (pi * arrow.rotateDegrees / 360);

    // is this the left or rigth arrow, changes direction of offset from original arrow
    if (leftArr) {
      arrRotation = arrRotation - offset / 180 * pi;
    } else {
      arrRotation = arrRotation + offset / 180 * pi;
    }
    // goes to starting position
    RotateEffect ef0 =
        RotateEffect.to(arrRotation, EffectController(duration: 0));
    add(ef0);

    // true if arrow should move right, more complicated because it first goes right then also left
    if (arrow.linEC.progress < 1) {
      // print('going right: $progress \narrDuration: ${arrow.duration}');
      linEC = LinearEffectController(arrow.duration);
      RotateEffect ef2 =
          RotateEffect.by(-pi * arrow.rotateDegrees / 180, linEC);
      linEC = LinearEffectController((1 - progress) * arrow.duration);
      RotateEffect ef1 = RotateEffect.by(
          pi * arrow.rotateDegrees / 180 * (1 - progress), linEC,
          onComplete: () {
        add(ef2); // move to the left end after that
      });
      add(ef1); // move to the right end first

      // if arrow should move left, easier because moves left and then new rotation cycle
    } else {
      // print('going left: $progress \narrDuration: ${arrow.duration}');
      linEC = LinearEffectController(progress * arrow.duration);
      RotateEffect ef1 =
          RotateEffect.by(-pi * arrow.rotateDegrees / 180 * progress, linEC);
      add(ef1);
    }
  }

  @override
  void update(double dt) {
    // if new rotation cycle needs to be started/ previous rotation finished
    if ((leftArr && arrow.changedECLeft) ||
        (!leftArr && arrow.changedECRight)) {
      if (leftArr) {
        arrow.checkedChangeECLeft();
      } else {
        arrow.checkedChangeECRight();
      }
      updateRotateEC();
      RotateEffect ef =
          RotateEffect.by(pi * arrow.rotateDegrees / 180, rotateEC);
      add(ef);
      // print('duration: ${arrow.duration}');
    }
  }

  void updateRotateEC() {
    linEC = LinearEffectController(arrow.duration);
    revLinEC = ReverseLinearEffectController(arrow.duration);
    rotateEC = SequenceEffectController([linEC, revLinEC]);
  }

  // shrink arrow after it is being fired (FlyingArrow actually flies)
  void shrinkArrow() {
    double flyDuration = 0.5 /
        (1 + (arrow.totalTime.elapsedMilliseconds / 1000) / arrow.level.arrInc);
    SequenceEffectController SEC = SequenceEffectController([
      LinearEffectController(0),
      ReverseLinearEffectController(flyDuration * 0.9)
    ]);
    ScaleEffect efShrink = ScaleEffect.to(Vector2(0.1, 0.1), SEC);
    add(efShrink);
  }

  changeColor() {
    final colorEf = ColorEffect(
      arrow.color,
      const Offset(0.0, 1),
      EffectController(duration: 0),
    );
    add(colorEf);
  }
}
