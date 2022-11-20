import 'dart:math';

import 'package:dot_shot/src/level_selection/levels.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

import '../play_session/level_screen.dart';
import '../style/palette.dart';
import 'arrow.dart';
import 'line.dart';

// Ball that moves across screen
class Ball extends CircleComponent
    with CollisionCallbacks, HasGameRef<DotShotGame> {
  final debugMode = false;
  GameLevel level;

  Stopwatch watch = Stopwatch(); // time since ball creation
  Stopwatch removeCounter =
      Stopwatch(); // starts when ball is hit, so that opacity effect can make ball disappear before ball is removed from screen
  double efDuration = 0.1; // time of opacity effect when ball is hit in seconds
  bool shouldRemove = false; // ball was hit and should be removed
  bool getPoint =
      false; // ball was hit by arrow => player receives point and arrows

  int milli; // time of game loop at which ball was created
  late TextComponent text;
  List<SpriteComponent> arrows = <SpriteComponent>[];
  int powerUp = 9; // powerUp that is activated when this ball is hit
  bool halfSpeed = false; // powerUp1
  int value = 1; // amount of arrows ball is worth
  double fontSize = 0; // font size of arrows in ball
  String valueArrs = '↟'; // arrows in ball
  List<Color> colors; // universal list of colors
  int ballColor;
  int ballNr = 99; // only relevant if one of first 3 balls meaning i < 3

  Ball(this.level, this.milli, this.colors, this.ballColor, this.powerUp,
      this.ballNr) {
    watch.start();
  }

  @override
  Future<void> onLoad() async {
    randValue();
    // start position, size, number?
    radius = gameRef.size.x * level.ballSize;
    anchor = Anchor.center;

    double rand = Random().nextDouble();
    double x = rand * (gameRef.size.x - radius * 2.6) + radius * 1.3;
    double y = 0 - radius * 2;
    if (ballNr < 99) {
      y += gameRef.getSpawnDistance() * (3 - ballNr);
      print('y is $y');
    }
    position = Vector2(x, y);
    // print('ball created at x: $x ');
    setColor(colors[ballColor]);

    CircleHitbox hitbox =
        CircleHitbox.relative(1, parentSize: Vector2(radius * 2, radius * 2));
    hitbox.collisionType = CollisionType.active;
    add(hitbox);

    // text/arrow in ball
    text = TextComponent(
        text: powerUp.toString(),
        anchor: Anchor.center,
        position: Vector2(radius, radius));
    if (powerUp < gameRef.powerUps.length) {
      add(text);
    } else {
      addInside();
    }
  }

  @override
  void update(double dt) {
    // if ball is still in game, it moves
    if (!removeCounter.isRunning) {
      super.update(dt);
      position = Vector2(position.x, position.y + getBallSpeed(dt));

      // when ball is supposed to be removed
    } else if (removeCounter.elapsedMilliseconds > (efDuration * 1000) - 50) {
      shouldRemove = true;
      // start powerUp if ball had one
      if (powerUp < gameRef.powerUps.length) {
        gameRef.startPowerUp(powerUp);
      }
    }
  }

  double getBallSpeed(double dt) {
    // move certain distance based on dt
    double totalTime = (milli + watch.elapsedMilliseconds) / 1000;
    // print(dt);
    double speed = level.ballSpeed * dt +
        dt * level.ballSpeed * (totalTime / level.ballInc);
    if (halfSpeed) {
      speed = speed * 0.5;
    }
    return speed; // linear function
  }

  // when ball touches another object with a hitbox
  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    // if ball was hit by arrow
    if (other is FlyingArrow &&
        (other.getColor() == colors[ballColor] ||
            other.getColor() == Palette().lightgray)) {
      // print('collision arrow');
      getPoint = true;

      OpacityEffect efOpa =
          OpacityEffect.to(0.1, EffectController(duration: efDuration));
      add(efOpa);
      if (text.isMounted) {
        remove(text);
      } else {
        // removeAll(arrows);
      }
      removeCounter.start();

      // ball hit bottom line
    } else if (other is Line) {
      // print('collision line');
      shouldRemove = true;
    } else if (other is Ball) {
      //print('collision ball');
    } else {
      // print('collision with what else???');
    }
  }

  // calculates amount of arrows this ball is worth depending on average value specified for level
  void randValue() {
    if (powerUp >= gameRef.powerUps.length) {
      double maxX = (level.avgPoints - 1) / 2;
      double randX = Random().nextDouble() * maxX;
      double randY = randX - level.avgPoints + 2;
      double rand = Random().nextDouble();

      if (rand <= randX) {
        value = 3;
        valueArrs = valueArrs + valueArrs + valueArrs;
      } else if (rand <= randX + randY) {
        value = 1;
      } else {
        value = 2;
        valueArrs = valueArrs + valueArrs;
      }
    } else {
      value = 2;
    }
  }

  // adds amount of arrows or text into inside of ball
  void addInside() {
    if (value == 2) {
      SpriteComponent sprite = getSprite();
      sprite.anchor = Anchor.centerRight;
      add(sprite);
      arrows.add(sprite);

      sprite = getSprite();
      sprite.anchor = Anchor.centerLeft;
      add(sprite);
      arrows.add(sprite);
    } else {
      SpriteComponent sprite = getSprite();
      add(sprite);
      arrows.add(sprite);
    }

    if (value == 3) {
      SpriteComponent sprite = getSprite();
      sprite.position = Vector2(sprite.x - sprite.width, sprite.y);
      arrows.add(sprite);
      add(sprite);

      sprite = getSprite();
      arrows.add(sprite);
      sprite.position = Vector2(sprite.x + sprite.width, sprite.y);
      add(sprite);
    }
  }

  // returns arrows in right size and color
  SpriteComponent getSprite() {
    SpriteComponent sprite = SpriteComponent(
        sprite: gameRef.arrSprite,
        size: Vector2(radius / 3, radius),
        anchor: Anchor.center,
        position: Vector2(radius, radius));
    ColorEffect colorEf = ColorEffect(
      Palette().lightgray,
      const Offset(0.0, 1),
      EffectController(duration: 0),
    );
    sprite.add(colorEf);
    return sprite;
  }

  void pauseGame() {
    watch.stop();
    removeCounter.stop();
  }

  void resumeGame() {
    watch.start();
    if (removeCounter.elapsedMilliseconds > 0) {
      removeCounter.start();
    }
  }

  // powerUp0
  setColorLightGray(bool light) {
    if (light) {
      setColor(Palette().lightgray);
      if (text.isMounted) {
        text.textRenderer = TextPaint(
            style: TextStyle(color: Palette().background, fontSize: fontSize));
      } else {
        for (SpriteComponent x in arrows) {
          ColorEffect colorEf = ColorEffect(
            Palette().background,
            const Offset(0.0, 1),
            EffectController(duration: 0),
          );
          x.add(colorEf);
        }
      }
    } else {
      // print('changing ball Color');
      setColor(colors[ballColor]);
      if (text.isMounted) {
        text.textRenderer = TextPaint(
            style: TextStyle(color: Palette().lightgray, fontSize: fontSize));
      } else {
        for (SpriteComponent x in arrows) {
          ColorEffect colorEf = ColorEffect(
            Palette().lightgray,
            const Offset(0.0, 1),
            EffectController(duration: 0),
          );
          x.add(colorEf);
        }
      }
    }
  }

  // powerUp1
  setHalfSpeed(bool half) {
    halfSpeed = half;
  }

  bool removeBall() => shouldRemove;
}
