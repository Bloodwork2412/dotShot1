// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dot_shot/src/style/button_style.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../player_progress/local_storage_player_progress_persistence.dart';
import '../style/palette.dart';
import 'main_background.dart';

// Main Menu screen without background, only buttons to select level and settings
class MainMenuScreen extends StatelessWidget {
  static const String id = 'mainMenuScreen';
  MainBackground gameRef;

  MainMenuScreen({Key? key, required this.gameRef}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();

    final modes = ["EASY", "MEDIUM", "DIFFICULT"];

    return Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(children: [
            Align(
                alignment: Alignment.topRight,
                child: Padding(
                    padding: EdgeInsets.fromLTRB(0, 12, 10, 0),
                    child: IconButton(
                      onPressed: () => GoRouter.of(context).go('/settings'),
                      icon: Icon(Icons.info_outline_rounded, size: 32),
                      color: palette.lightgray,
                    ))),
            Expanded(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                modes.length,
                (index) {
                  return Column(
                    children: [
                      FutureBuilder<int>(
                          future: LocalStoragePlayerProgressPersistence().getHighscore(index + 1),
                          builder: (context, AsyncSnapshot snapshot) {
                            String text = 'Highscore: ';
                            if (!snapshot.hasData) {
                              text = text + '0';
                              return MyButton(
                                  text: modes[index],
                                  subText: text,
                                  onPressed: () {
                                    //  final audioController = context.read<AudioController>();
                                    //  audioController.playSfx(SfxType.buttonTap);
                                    GoRouter.of(context).go('/session/${index + 1}');
                                  });
                            } else {
                              text = text + snapshot.data.toString();
                              // print('highscore Text: $text');
                              return MyButton(
                                  text: modes[index],
                                  subText: text,
                                  onPressed: () {
                                    //  final audioController = context.read<AudioController>();
                                    //  audioController.playSfx(SfxType.buttonTap);
                                    GoRouter.of(context).go('/session/${index + 1}');
                                  });
                            }
                          }),
                      SizedBox(
                        height: 48,
                      )
                    ],
                  );

                  // modes[index].toString(),
                },
              ),
            ))
          ]),
        ));
  }
}
