import 'package:flame/components.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

import 'dart:async';
import 'package:flutter/material.dart';

import 'package:flame/events.dart' as events;
import 'package:flame/extensions.dart';
import 'package:flame_forge2d/forge2d_game.dart';
import 'package:flame_forge2d/forge2d_world.dart';
import 'package:zymixx_todo_list/data/flame/components/circle_bounce.dart';
import 'package:zymixx_todo_list/data/flame/components/wall_bounce.dart';

class WallBgFlameWidget extends StatelessWidget {
  WallBgFlameWidget({super.key});
  late GameBounce gameBounce;

  @override
  Widget build(BuildContext context) {
    gameBounce = GameBounce();
    return Center(
      child: IgnorePointer(
        ignoring: true,
        child: GameWidget(game: gameBounce,
            autofocus: true,
        ),
      ),
    );
  }

}


class GameBounce extends Forge2DGame {

  GameBounce() : super(world: WorldBounce());


  void applyRandomMove() {
    (world as WorldBounce).applyRandomMove();
  }

  @override
  Future<void> onLoad() async {
    images.prefix = 'assets/';
  }

  @override
  Color backgroundColor() => const Color(0x00000000);
}

class WorldBounce extends Forge2DWorld with events.TapCallbacks, events.PointerMoveCallbacks {
  events.PointerMoveEvent? mouseEvent;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    gravity = Vector2.zero();
    add(WallBounce());
    for (var i = 0; i < 30; i++) {
      add(CircleBounce(initPosition: Vector2((i*1)%10,0+i/10)));
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
  }

  @override
  void onPointerMove(events.PointerMoveEvent event) {
    mouseEvent = event;
   // print('MOVE');
  }

  applyRandomMove(){
    for (var child in children) {
      if (child is CircleBounce) {
        child.applyRandomForce(3000);
      }
    }
  }
}
