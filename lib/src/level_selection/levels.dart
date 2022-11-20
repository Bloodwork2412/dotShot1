// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

const gameLevels = [
  GameLevel(
    number: 1, // number of Game Level
    arrSpeed: 2.5, // time arrow needs to cross screen at start
    arrInc: 55, // arrow speed doubles after arrInc seconds (linear)
    ballSize: 0.1, // radius = screenwidth * ballSize
    ballSpeed: 30, // start speed of ball
    ballInc: 50, // ball speed doubles after ballInc seconds (linear)
    spawn: 0.8, // spawn distance at start in radius
    spawnInc: 40, // spawn distance is half after spawnInc seconds
    avgPoints: 1.7,
    // TODO: When ready, change these achievement IDs.
    // You configure this in App Store Connect.
    achievementIdIOS: 'first_win',
    // You get this string when you configure an achievement in Play Console.
    achievementIdAndroid: 'NhkIwB69ejkMAOOLDb',
  ),
  GameLevel(
    number: 2, // number of Game Level
    arrSpeed: 2, // time arrow needs to cross screen at start
    arrInc: 50, // arrow speed doubles after arrInc seconds (linear)
    ballSize: 0.085, // radius = screenwidth * ballSize
    ballSpeed: 40, // start speed of ball
    ballInc: 45, // ball speed doubles after ballInc seconds (linear)
    spawn: 0.6, // spawn distance at start in radius
    spawnInc: 40, // spawn distance is half after spawnInc seconds
    avgPoints: 1.6,
  ),
  GameLevel(
    number: 3, // number of Game Level
    arrSpeed: 1.6, // time arrow needs to cross screen at start
    arrInc: 45, // arrow speed doubles after arrInc seconds (linear)
    ballSize: 0.07, // radius = screenwidth * ballSize
    ballSpeed: 50, // start speed of ball
    ballInc: 40, // ball speed doubles after ballInc seconds (linear)
    spawn: 0.5, // spawn distance at start in radius
    spawnInc: 40, // spawn distance is half after spawnInc seconds
    avgPoints: 1.5,
    achievementIdIOS: 'finished', // never used
    achievementIdAndroid: 'CdfIhE96aspNWLGSQg', // never used
  ),
];

// all parameters that have to be specified for each difficulty
class GameLevel {
  final int number; //Difficulty/Level number

  final double arrSpeed; //start speed of arrow
  final double arrInc; //arrow speed increase factor

  final double ballSize;
  final double ballSpeed; // start speed of balls
  final double ballInc; // ball speed increase factor

  final double spawn; // ball spawn start time
  final double spawnInc; // ball spawn increase factor

  final double avgPoints; // average amount of arrows a ball is worth

  /// The achievement to unlock when the level is finished, never used
  final String? achievementIdIOS;
  final String? achievementIdAndroid;
  bool get awardsAchievement => achievementIdAndroid != null;

  const GameLevel({
    required this.number,
    required this.arrSpeed,
    required this.arrInc,
    required this.ballSize,
    required this.ballSpeed,
    required this.ballInc,
    required this.spawn,
    required this.spawnInc,
    required this.avgPoints,
    this.achievementIdIOS,
    this.achievementIdAndroid,
  }) : assert(
            (achievementIdAndroid != null && achievementIdIOS != null) ||
                (achievementIdAndroid == null && achievementIdIOS == null),
            'Either both iOS and Android achievement ID must be provided, '
            'or none');
}
