import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../level_selection/levels.dart';
import '../main_menu/game_state_cubit.dart';
import 'level_screen.dart';
import 'overlays/game_over_menu.dart';
import 'overlays/pause_button.dart';
import 'overlays/pause_menu.dart';

// basically parent of level_screen and all overlays
class GameScreen extends StatelessWidget {
  late DotShotGame game;
  final GameLevel level;

  GameScreen(this.level, {super.key}) {}

  @override
  Widget build(BuildContext context) {
    print("loading GameScreen");
    return BlocProvider(
      create: (BuildContext context) => GameStateCubit(),
      child: SafeArea(
        child: GameWidget(
          game: DotShotGame(level),
          initialActiveOverlays: const [PauseButton.id],
          overlayBuilderMap: {
            PauseButton.id: (context, DotShotGame gameRef) => PauseButton(
                  gameRef: gameRef,
                ),
            PauseMenu.id: (context, DotShotGame gameRef) => PauseMenu(
                  gameRef: gameRef,
                ),
            Countdown.id: (context, DotShotGame gameRef) => Countdown(
                  gameRef: gameRef,
                ),
            GameOverMenu.id: (context, DotShotGame gameRef) => GameOverMenu(
                  gameRef: gameRef,
                ),
          },
        ),
      ),
    );
  }
}
