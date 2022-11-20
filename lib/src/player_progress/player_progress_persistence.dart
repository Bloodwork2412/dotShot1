// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// An interface of persistence stores for the player's progress.
///
/// Implementations can range from simple in-memory storage through
/// local preferences to cloud saves.

// saves high score of each level
abstract class PlayerProgressPersistence {
  Future<int> getHighscore1();
  Future<void> saveHighscore1(int score);

  Future<int> getHighscore2();
  Future<void> saveHighscore2(int score);

  Future<int> getHighscore3();
  Future<void> saveHighscore3(int score);
}
