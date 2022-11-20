import 'package:flame/game.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'game_state_cubit.dart';
import 'main_background.dart';
import 'main_menu_screen.dart';

// Main Menu, basically parent class of every screen
class MainMenu extends StatelessWidget {
  MainMenu({super.key}) {}

  @override
  Widget build(BuildContext context) {
    print("loading MainMenu");
    return BlocProvider(
      create: (BuildContext context) => GameStateCubit(),
      //child: SafeArea(
      child: GameWidget(
        game: MainBackground(),
        initialActiveOverlays: const [MainMenuScreen.id],
        overlayBuilderMap: {
          MainMenuScreen.id: (context, MainBackground gameRef) =>
              MainMenuScreen(
                gameRef: gameRef,
              ),
        },
      ),
      //),
    );
  }
}
