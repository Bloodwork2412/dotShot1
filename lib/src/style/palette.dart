// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';

/// A palette of colors to be used in the game.
///
/// The reason we're not going with something like Material Design's
/// `Theme` is simply that this is simpler to work with and yet gives
/// us everything we need for a game.
///
/// Games generally have more radical color palettes than apps. For example,
/// every level of a game can have radically different colors.
/// At the same time, games rarely support dark mode.
///
/// Colors here are implemented as getters so that hot reloading works.
/// In practice, we could just as easily implement the colors
/// as `static const`. But this way the palette is more malleable:
/// we could allow players to customize colors, for example,
/// or even get the colors from the network.

class Palette {
  /*
  Color get background => const Color(0xfff5f5f5);
  Color get overlayBg => const Color(0x12000000);
  Color get lightgray => const Color(0xff253a34);
  // 3 Ball colors
  Color get color1 => const Color(0xffec5b84);
  Color get color2 => const Color(0xff26c485);
  Color get color3 => const Color(0xff00b4f5);

  // Galaxy colors
  Color get background => const Color(0xff090909);
  Color get overlayBg => const Color(0x12000000);
  Color get lightgray => const Color(0xffd6d6d6);
  Color get color1 => const Color(0xffffdd1f);
  Color get color2 => const Color(0xffec008d);
  Color get color3 => const Color(0xff05abec);

  //Japan spring colors
  Color get background => const Color(0xffd1fdfb);
  Color get overlayBg => const Color(0x12000000);
  Color get lightgray => const Color(0xff4f282e);
  Color get color1 => const Color(0xfff6c0d7);
  Color get color2 => const Color(0xff96c877);
  Color get color3 => const Color(0xfff6ee63);
*/
  //Ice cream colors (best)
  Color get background => const Color(0xff0d1321);
  Color get overlayBg => const Color(0x12000000);
  Color get lightgray => const Color(0xffebf5ee);
  Color get color1 => const Color(0xfffec601);
  Color get color2 => const Color(0xff24a2e0);
  Color get color3 => const Color(0xffe84855);
}
