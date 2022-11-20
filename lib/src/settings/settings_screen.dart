// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dot_shot/src/style/button_style.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../style/palette.dart';
import '../style/responsive_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette().background,
      body: ResponsiveScreen(
        squarishMainArea: Center(
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text('game by\nNOEL BILLING\n\ntesting by\nVIOLA\nLINUS\nBOTTOND',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 35,
                  ))),
        ),
        rectangularMenuArea: MyButton(
          text: 'Back',
          onPressed: () {
            GoRouter.of(context).pop();
          },
        ),
      ),
    );
  }
}
