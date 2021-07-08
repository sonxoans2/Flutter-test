import 'dart:math';
import 'dart:ui';

import 'package:ShootFlies/components/fly/fly.dart';
import 'package:ShootFlies/components/highscore-display.dart';
import 'package:ShootFlies/components/music-button.dart';
import 'package:ShootFlies/components/sound-button.dart';
import 'package:ShootFlies/view.dart';
import 'package:ShootFlies/views/home-view.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/gestures.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'components/fly/agile-fly.dart';
import 'components/backyard.dart';
import 'components/credits-button.dart';
import 'components/fly/drooler-fly.dart';
import 'components/help-button.dart';
import 'components/fly/house-fly.dart';
import 'components/fly/hungry-fly.dart';
import 'components/fly/macho-fly.dart';
import 'components/score-display.dart';
import 'components/start-button.dart';
import 'controllers/spawner.dart';
import 'views/credits-view.dart';
import 'views/help-view.dart';
import 'views/lost-view.dart';

import 'package:audioplayers/audioplayers.dart';

class LangawGame extends Game {
  Size screenSize;
  double tileSize;

  List<Fly> flies;
  Random rnd;
  Backyard background;
  View activeView = View.home;
  HomeView homeView;
  StartButton startButton;
  LostView lostView;

  FlySpawner spawner;

  HelpButton helpButton;
  CreditsButton creditsButton;
  HelpView helpView;
  CreditsView creditsView;
  ScoreDisplay scoreDisplay;
  int score;
  HighscoreDisplay highscoreDisplay;

  final SharedPreferences storage;
  AudioPlayer homeBGM;
  AudioPlayer playingBGM;

  MusicButton musicButton;
  SoundButton soundButton;
  LangawGame(this.storage) {
    initialize();
  }

  void initialize() async {
    flies = List<Fly>();
    rnd = Random();
    resize(await Flame.util.initialDimensions());
    background = Backyard(this);
    homeView = HomeView(this);
    startButton = StartButton(this);
    lostView = LostView(this);
    // spawnFly();
    spawner = FlySpawner(this);
    helpButton = HelpButton(this);
    creditsButton = CreditsButton(this);
    helpView = HelpView(this);
    creditsView = CreditsView(this);
    scoreDisplay = ScoreDisplay(this);
    highscoreDisplay = HighscoreDisplay(this);

    musicButton = MusicButton(this);
    soundButton = SoundButton(this);

    score = 0;

    homeBGM = await Flame.audio.loop('bgm/home.mp3', volume: .25);
    homeBGM.pause();
    playingBGM = await Flame.audio.loop('bgm/playing.mp3', volume: .25);
    playingBGM.pause();

    playHomeBGM();
  }

  void playHomeBGM() {
    playingBGM.pause();
    playingBGM.seek(Duration.zero);

    if (musicButton.isEnabled) homeBGM.resume();
  }

  void playPlayingBGM() {
    homeBGM.pause();
    homeBGM.seek(Duration.zero);
    if (musicButton.isEnabled) playingBGM.resume();
  }

  @override
  void render(Canvas canvas) {
    background.render(canvas);
    highscoreDisplay.render(canvas);
    musicButton.render(canvas);
    soundButton.render(canvas);
    if (activeView == View.playing) scoreDisplay.render(canvas);
    flies.forEach((Fly fly) => fly.render(canvas));
    if (activeView == View.home) homeView.render(canvas);
    if (activeView == View.lost) lostView.render(canvas);
    if (activeView == View.home || activeView == View.lost) {
      startButton.render(canvas);
      helpButton.render(canvas);
      creditsButton.render(canvas);
    }
    if (activeView == View.help) helpView.render(canvas);
    if (activeView == View.credits) creditsView.render(canvas);
  }

  @override
  void update(double t) {
    spawner.update(t);
    flies.forEach((Fly fly) => fly.update(t));
    flies.removeWhere((Fly fly) => fly.isOffScreen);
    if (activeView == View.playing) scoreDisplay.update(t);
  }

  void resize(Size size) {
    screenSize = size;
    tileSize = screenSize.width / 9;
  }

  void spawnFly() {
    double x = rnd.nextDouble() * (screenSize.width - tileSize);
    double y = rnd.nextDouble() * (screenSize.height - tileSize);
    switch (rnd.nextInt(5)) {
      case 0:
        flies.add(HouseFly(this, x, y));
        break;
      case 1:
        flies.add(DroolerFly(this, x, y));
        break;
      case 2:
        flies.add(AgileFly(this, x, y));
        break;
      case 3:
        flies.add(MachoFly(this, x, y));
        break;
      case 4:
        flies.add(HungryFly(this, x, y));
        break;
    }
  }

  void onTapDown(TapDownDetails d) {
    bool isHandled = false;
// dialog boxes
    if (!isHandled) {
      if (activeView == View.help || activeView == View.credits) {
        activeView = View.home;
        isHandled = true;
      }
    }

    // help button
    if (!isHandled && helpButton.rect.contains(d.globalPosition)) {
      if (activeView == View.home || activeView == View.lost) {
        helpButton.onTapDown();
        isHandled = true;
      }
    }

// credits button
    if (!isHandled && creditsButton.rect.contains(d.globalPosition)) {
      if (activeView == View.home || activeView == View.lost) {
        creditsButton.onTapDown();
        isHandled = true;
      }
    }
    // music button
    if (!isHandled && musicButton.rect.contains(d.globalPosition)) {
      musicButton.onTapDown();
      isHandled = true;
    }

// sound button
    if (!isHandled && soundButton.rect.contains(d.globalPosition)) {
      soundButton.onTapDown();
      isHandled = true;
    }
    if (!isHandled && startButton.rect.contains(d.globalPosition)) {
      if (activeView == View.home || activeView == View.lost) {
        startButton.onTapDown();
        isHandled = true;
      }
    }
    if (!isHandled) {
      bool didHitAFly = false;
      flies.forEach((Fly fly) {
        if (fly.flyRect.contains(d.globalPosition)) {
          fly.onTapDown();
          isHandled = true;
          didHitAFly = true;
        }
      });
      if (activeView == View.playing && !didHitAFly) {
        if (soundButton.isEnabled) {
          Flame.audio
              .play('sfx/haha' + (rnd.nextInt(5) + 1).toString() + '.ogg');
        }
        playHomeBGM();
        activeView = View.lost;
      }
    }
  }
}
