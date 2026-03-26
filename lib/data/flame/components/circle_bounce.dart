import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zymixx_todo_list/data/flame/hover_observer.dart';

class CircleBounce extends BodyComponent
    with ContactCallbacks, CollisionCallbacks, HoverCallbacks {
  final Vector2 initPosition;
  late Vector2 size;
  Vector2 velocity = Vector2(1, 0);
  bool isHovered = false;
  late SpriteComponent spriteComponent;
  late CircleShape shape;
  double radius = 7.5;

  double forceMagnitude = 200.0;

  final double maxAngularVelocity = 3.0;

  static const int burstTapCount = 5;
  static const int burstFrameCount = 5;
  static const double burstStepTime = 0.015;
  int _tapCount = 0;
  bool _isBursting = false;
  late final SpriteAnimation _burstAnimation;

  double get hitRadius => radius * 0.75;


  CircleBounce({
    required this.initPosition,
  }) : super();

  @override
  Future<void> onLoad() async {
    shape = CircleShape();
    // Физический коллайдер оставляем небольшим, чтобы не ломать динамику.
    // Для тапа/реакции курсора используем отдельный hitRadius ниже.
    shape.radius = radius / 2;
    size = Vector2(radius , radius );
    final sprite = await Sprite.load('bubble.png');

    // Кадры анимации взрыва (buddle_1..buddle_5) пронумерованы и выровнены.
    final burstSprites = await Future.wait(
      List.generate(burstFrameCount, (i) {
        final frameIndex = i + 1;
        return Sprite.load('buddle_animation/buddle_$frameIndex.png');
      }),
    );
    _burstAnimation = SpriteAnimation.spriteList(
      burstSprites,
      stepTime: burstStepTime,
      loop: false,
    );

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
    Get.find<CursorPositionService>().cursorPositionStream.listen((globalPos) {
      applyOppositeForce(globalPos);
    });

    Get.find<CursorPositionService>().pointerDownStream.listen((globalPos) {
      _handlePointerDown(globalPos);
    });
    return super.onLoad();
  }

  void _handlePointerDown(Offset globalPos) {
    if (_isBursting) return;

    // ignore: avoid_print
    print('CircleBounce _handlePointerDown');

    // Проверяем попадание по “видимому” радиусу, а координаты берём в
    // общем (global) пространстве Flutter/Flame, как и для курсора.
    final testLocal = globalPos.toVector2();
    final cursorPos = camera.globalToLocal(testLocal);

    if ((cursorPos - position).length2 > hitRadius * hitRadius) return;

    _tapCount++;
    if (_tapCount >= burstTapCount) {
      _startBurst();
    }
  }

  void _startBurst() {
    _isBursting = true;
    // ignore: avoid_print
    print('CircleBounce: BURST');

    final currentAngle = body.angle;

    // Замораживаем физическое вращение/движение, чтобы анимация была “статична”
    // относительно текущего угла (шарики могут крутиться).
    body.linearVelocity = Vector2.zero();
    body.angularVelocity = 0;

    // Убираем idle-спрайт и запускаем анимацию взрыва.
    spriteComponent.removeFromParent();

    add(
      SpriteAnimationComponent(
        animation: _burstAnimation,
        size: size * 1.5,
        position: Vector2.zero(),
        // Родительский BodyComponent вращает canvas на body.angle.
        // Мы “откатываем” угол, чтобы кадры взрыва были выровнены с idle-ориентацией.
        angle: -currentAngle,
        anchor: Anchor.center,
        removeOnFinish: true,
      ),
    );

    // Flame 1.15 не имеет onComplete у SpriteAnimationComponent,
    // поэтому удаляем тело пузырька по известной длительности.
    final burstDurationMs =
        (burstStepTime * burstFrameCount * 1000).round();
    Future.delayed(Duration(milliseconds: burstDurationMs), () {
      if (!isMounted) return;
      removeFromParent();
    });
  }

  @override
  void update(double dt) {
    if (_isBursting) {
      // Во время анимации взрыва держим физику “на месте”,
      // чтобы углы и выравнивание кадров оставались корректными.
      body.linearVelocity = Vector2.zero();
      body.angularVelocity = 0;
      super.update(dt);
      return;
    }

    if (body.angularVelocity > maxAngularVelocity) {
      body.angularVelocity = maxAngularVelocity;
    } else if (body.angularVelocity < -maxAngularVelocity) {
      body.angularVelocity = -maxAngularVelocity;
    }
    super.update(dt);
  }

  void applyOppositeForce(Offset globalPos) {
    if (_isBursting) return;

    final testLocal = globalPos.toVector2();
    Vector2 cursorPos = camera.globalToLocal(testLocal);
    // Используем отдельный hitRadius для реакции на курсор,
    // чтобы тапы/перетаскивание не зависели от размера физического коллайдера.
    if ((cursorPos - position).length2 <= hitRadius * hitRadius) {
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

  // Делаем тап “кликом по видимому шарику”, а не по маленькому физическому коллайдеру.
  // Это позволяет оставить корректную физику (столкновения) и при этом стабильно ловить клики.
  @override
  bool containsLocalPoint(Vector2 point) {
    return point.length2 <= hitRadius * hitRadius;
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
