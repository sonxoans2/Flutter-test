import 'dart:ui';

import 'package:ShootFlies/langaw-game.dart';
import 'package:flame/sprite.dart';
import 'fly.dart';

class AgileFly extends Fly {
  double get speed => game.tileSize * 5;
  AgileFly(LangawGame game, double x, double y) : super(game) {
    flyRect = Rect.fromLTWH(x, y, game.tileSize, game.tileSize);
    flyingSprite = List();
    flyingSprite.add(Sprite('flies/agile-fly-1.png'));
    flyingSprite.add(Sprite('flies/agile-fly-2.png'));
    deadSprite = Sprite('flies/agile-fly-dead.png');
  }
}
