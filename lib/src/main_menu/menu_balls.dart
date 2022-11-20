import 'dart:math';
import 'dart:ui';

import 'package:dot_shot/src/level_selection/levels.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import 'main_background.dart';

// Balls used in the Main menu background
class MenuBall extends CircleComponent
    with CollisionCallbacks, HasGameRef<MainBackground> {
  bool shouldRemove = false;
  int speed;
  double yPos;
  Color ballColor;
  List<GameLevel> levels = gameLevels;
  List<MenuBall> balls;

  MenuBall(this.balls, this.ballColor, this.speed, this.yPos) {}

  @override
  Future<void> onLoad() async {
    // start position, size, number?
    double randRadius = levels[levels.length - 1].ballSize +
        Random().nextDouble() *
            (levels[0].ballSize - levels[levels.length - 1].ballSize);
    radius = gameRef.size.x * randRadius;

    anchor = Anchor.center;

    int n = 0;
    double x = findX();
    // new ball needs certain distance from last 2 balls or new position will be created
    while ((balls.length >= 2 &&
            x + 2 * radius > balls[balls.length - 2].x &&
            x - 2 * radius < balls[balls.length - 2].x) ||
        (balls.length >= 3 &&
            x + 1 * radius > balls[balls.length - 3].x &&
            x - 1 * radius < balls[balls.length - 3].x)) {
      x = findX();
      n++;
    }
    // print('$n tries');
    // print(radius);
    position = Vector2(x, yPos);
    // position = Vector2(10, 10);
    // print('ball created at x: $position ');
    setColor(ballColor);
  }

  // get a random x axis position
  double findX() {
    // print('findX');
    double rand = Random().nextDouble();
    double x = rand * (gameRef.size.x);
    return x;
  }

  // move balls down
  @override
  void update(double dt) {
    super.update(dt);
    position = Vector2(position.x, position.y + speed * dt);
    // print('pos: $position');
    if (position.y - radius * 2 > gameRef.size.y) {
      shouldRemove = true;
      // print('remove');
    }
  }

  bool removeBall() => shouldRemove;
}
