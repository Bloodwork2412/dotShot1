import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../style/palette.dart';

// the line above the arrow
class Line extends PositionComponent with HasGameRef {
  final debugMode = false;
  static const numLines = 10; // amount of lines across screen
  double lineYPos;
  double rectHeight = 0; // height of small rectangles in line
  Stopwatch watch = Stopwatch(); // measures how long line is red

  // line properties
  Paint _linePaint = Paint()
    ..color = Palette().lightgray
    ..isAntiAlias = false;

  Line(this.lineYPos) {}

  @override
  Future<void> onLoad() async {
    RectangleHitbox hitbox = RectangleHitbox(
        size: Vector2(gameRef.size.x, 10),
        position: Vector2(0, lineYPos),
        anchor: Anchor.topLeft);
    hitbox.collisionType = CollisionType.passive;
    add(hitbox);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
  }

  @override
  void render(Canvas canvas) {
    // height and width of lines always relative to screen size
    double width = gameRef.size.x / (numLines * 2);
    rectHeight = width / 5;

    // half a line space on each side and on lower 1/4 of screen
    canvas
      ..save()
      ..translate(width / 2, gameRef.size.y / 4 * 3);

    // draws lines
    for (var i = 0; i < numLines; i++) {
      canvas
        ..drawRect(Offset(0, 0) & Size(width, rectHeight), _linePaint)
        ..translate(width * 2, 0);
    }
    canvas.restore();
  }

  // after error color goes back to normal color
  @override
  void update(double dt) {
    super.update(dt);
    if (watch.elapsedMilliseconds > 250) {
      watch.stop();
      watch.reset();
      _linePaint.color = Palette().lightgray;
    }
  }

  // turns red for specified time when collides with ball
  void errorColor() {
    _linePaint.color = Palette().color3;
    watch.reset();
    watch.start();
  }
}

// line that indicates how much time is left during powerUps
class TimeLine extends RectangleComponent {
  late RectangleComponent timeLine;
  double lineYPos;
  double width;
  double duration;
  double rectHeight;
  double timeLineHeight = 7;
  Stopwatch watch = Stopwatch();
  late LinearEffectController efController;

  TimeLine(this.duration, this.lineYPos, this.width, this.rectHeight) {
    // print('added timeLine');
  }

  @override
  Future<void> onLoad() async {
    timeLine = RectangleComponent(
      anchor: Anchor.topLeft,
      position: Vector2(0, lineYPos - ((timeLineHeight - rectHeight) / 2)),
      size: Vector2(width, timeLineHeight),
    );
    setColor(Palette().lightgray);

    // simply moves from right to left, makes it look shorter over time
    efController = LinearEffectController(duration);
    MoveEffect ef = MoveEffect.by(Vector2(-width, 0), efController);

    add(timeLine);
    add(ef);
  }

  // duration of each powerUp
  double getDuration() {
    switch (0) {
      case 0: // arrow and balls light gray
        return 5;
      case 1: // unlimited Arrows
        return 5;
      case 2: // reflective Arrow
        return 5;
      case 3: // balls and arrow white
        return 5;
      default: // several Arrows
        return 5;
    }
  }

  // turns back to normal color after 250 ms
  @override
  void update(double dt) {
    super.update(dt);
    if (watch.elapsedMilliseconds > 250) {
      watch.stop();
      watch.reset();
      timeLine.setColor(Palette().lightgray);
    }
  }

  // turns red for specified time when collides with ball
  void errorColor() {
    // print('set color of timeLine');
    timeLine.setColor(Palette().color3);
    watch.reset();
    watch.start();
  }
}
