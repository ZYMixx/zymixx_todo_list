import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:zymixx_todo_list/data/flame/hover_observer.dart';

class CircleBounce extends BodyComponent with ContactCallbacks, CollisionCallbacks, HoverCallbacks {
  final Vector2 initPosition;
  late Vector2 size;
  Vector2 velocity = Vector2(1, 0);
  bool isHovered = false;
  late SpriteComponent spriteComponent;
  late CircleShape shape;
  double radius = 7.5;

  double forceMagnitude = 200.0;

  final double maxAngularVelocity = 3.0;


  CircleBounce({
    required this.initPosition,
  }) : super();

  @override
  Future<void> onLoad() async {
    shape = CircleShape();
    shape.radius = radius/2;
    size = Vector2(radius , radius );
    final sprite = await Sprite.load('bubble.png');
    // Создаем SpriteComponent
    spriteComponent = SpriteComponent(
      sprite: sprite,
      size: size*1.5,
      position: Vector2.zero(),
      anchor: Anchor.center,
      paint: Paint()..color = const Color.fromRGBO(255, 255, 255, 0.75), // Устанавливаем прозрачность на 50%
      // scale: Vector2(3,3),
    );
    add(spriteComponent);

    // debugMode = true;
    Get.find<CursorPositionService>().cursorPositionStream.listen((eventPos) {
      applyOppositeForce(eventPos);
    });
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (body.angularVelocity > maxAngularVelocity) {
      body.angularVelocity = maxAngularVelocity;
    } else if (body.angularVelocity < -maxAngularVelocity) {
      body.angularVelocity = -maxAngularVelocity;
    }
    super.update(dt);
  }

  void applyOppositeForce(PointerHoverEvent eventPos) {
    var testLocal = eventPos.position.toVector2();
    Vector2 cursorPos = camera.globalToLocal(testLocal);
    if (containsPoint(cursorPos)) {
      Vector2 direction = position - cursorPos;
      direction.normalize();
      // const forceMagnitude = 21000.0;
      Vector2 force = direction * forceMagnitude;
      body.applyForce(force, point: body.worldCenter);
    }
  }

  applyForce(Vector2 forceVector) {
    body.applyForce(forceVector, point: body.worldCenter);
  }

  applyRandomForce(double force) {
    Vector2 randomDirection = Vector2.random() * 2 - Vector2.all(1);
    Vector2 forceVector = randomDirection * force;
    body.applyForce(forceVector, point: body.worldCenter);
  }

  @override
  Body createBody() {
    paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..imageFilter = ImageFilter.blur(sigmaX: 0.55, sigmaY: 0.55, tileMode: TileMode.decal);
        final fixtureDef = FixtureDef(
      shape,
      userData: this,
      friction: 0.6,
      restitution: 0.6,
      density: 0.6,
    );
    final bodyDef = BodyDef(
      position: initPosition,
      type: BodyType.dynamic,
      angularDamping : 4.0, // Запрещаем вращение
      //fixedRotation: true, // Запрещаем вращение
    );
    final ground = world.createBody(bodyDef);
    ground.createFixture(fixtureDef);
    return ground;
  }
}
