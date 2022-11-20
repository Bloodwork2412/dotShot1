// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:shared_preferences/shared_preferences.dart';

import 'player_progress_persistence.dart';

/// An implementation of [PlayerProgressPersistence] that uses
/// `package:shared_preferences`.
class LocalStoragePlayerProgressPersistence extends PlayerProgressPersistence {
  final Future<SharedPreferences> instanceFuture =
      SharedPreferences.getInstance();

  Future<int> getHighscore(int level) async {
    switch (level) {
      case 1:
        {
          return getHighscore1();
        }
      case 2:
        {
          return getHighscore2();
        }
      default:
        {
          return getHighscore3();
        }
    }
  }

  void saveHighscore(int level, int score) {
    switch (level) {
      case 1:
        {
          saveHighscore1(score);
          break;
        }
      case 2:
        {
          saveHighscore2(score);
          break;
        }
      default:
        {
          saveHighscore3(score);
          break;
        }
    }
  }

  void reset() {
    saveHighscore1(0);
    saveHighscore2(0);
    saveHighscore3(0);
  }

  @override
  Future<int> getHighscore1() async {
    final prefs = await instanceFuture;
    // print((prefs.getInt('highscore1') ?? 88).toString());
    return prefs.getInt('highscore1') ?? 0;
  }

  @override
  Future<void> saveHighscore1(int score) async {
    final prefs = await instanceFuture;
    await prefs.setInt('highscore1', score);
  }

  @override
  Future<int> getHighscore2() async {
    final prefs = await instanceFuture;
    return prefs.getInt('highscore2') ?? 0;
  }

  @override
  Future<void> saveHighscore2(int score) async {
    final prefs = await instanceFuture;
    await prefs.setInt('highscore2', score);
  }

  @override
  Future<int> getHighscore3() async {
    final prefs = await instanceFuture;
    return prefs.getInt('highscore3') ?? 0;
  }

  @override
  Future<void> saveHighscore3(int score) async {
    final prefs = await instanceFuture;
    // print('saveHighscore $score');
    await prefs.setInt('highscore3', score);
  }
}
