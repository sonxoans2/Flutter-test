import 'dart:ui';

import 'package:flame/sprite.dart';

import 'package:ShootFlies/langaw-game.dart';
import 'fly.dart';

class HungryFly extends Fly {
  HungryFly(LangawGame game, double x, double y) : super(game) {
    flyRect = Rect.fromLTWH(x, y, game.tileSize, game.tileSize);
    flyingSprite = List();
    flyingSprite.add(Sprite('flies/hungry-fly-1.png'));
    flyingSprite.add(Sprite('flies/hungry-fly-2.png'));
    deadSprite = Sprite('flies/hungry-fly-dead.png');
  }
}
