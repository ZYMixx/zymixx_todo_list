import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

class WallBounce extends BodyComponent{

  late Body testBody;
  List<Body> wallList = [];

  @override
  Future<void> onLoad() {
    buildAll();
    return super.onLoad();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    for (var body in wallList){
      world.destroyBody(body);
    }
    buildAll();
  }

  void buildAll() {
    // Получаем размеры экрана в мировых координатах
    final Vector2 topLeft = game.screenToWorld(Vector2.zero());
    final Vector2 bottomRight = game.screenToWorld(game.size);

    // Устанавливаем границы экрана
    // Верхняя граница
    addBoundary(Vector2(topLeft.x, topLeft.y), Vector2(bottomRight.x, topLeft.y));

    // Нижняя граница
    addBoundary(Vector2(topLeft.x, bottomRight.y), Vector2(bottomRight.x, bottomRight.y));

    // Левая граница
    addBoundary(Vector2(topLeft.x, topLeft.y), Vector2(topLeft.x, bottomRight.y));

    // Правая граница
    addBoundary(Vector2(bottomRight.x, topLeft.y), Vector2(bottomRight.x, bottomRight.y));
  }

  FixtureDef calculateFixture(Vector2 start, Vector2 end){
    final edgeShape = EdgeShape()..set(start, end);
    return FixtureDef(edgeShape);
  }


  Body addBoundary(Vector2 start, Vector2 end) {
    final edgeShape = EdgeShape()..set(start, end);
    final fixtureDef = FixtureDef(edgeShape);
    final bodyDef = BodyDef(type: BodyType.kinematic,);
    final body = world.createBody(bodyDef);
    body.createFixture(fixtureDef);
    wallList.add(body);
    return body;
  }

  @override
  Body createBody() {
    return world.createBody(BodyDef());
  }

}

// void createScreenBoundaries() {
//   final screenSize = game.size; // Используем размер экрана игры
//   addBoundary(Vector2(0, 0), Vector2(screenSize.x, 0)); // Top
//   addBoundary(Vector2(0, screenSize.y), Vector2(screenSize.x, screenSize.y)); // Bottom
//   addBoundary(Vector2(0, 0), Vector2(0, screenSize.y)); // Left
//   addBoundary(Vector2(screenSize.x, 0), Vector2(screenSize.x, screenSize.y)); // Right
// }
//
// void addBoundary(Vector2 start, Vector2 end) {
//   final edgeShape = EdgeShape()..set(start, end);
//   final fixtureDef = FixtureDef(edgeShape, userData: this);
//   final bodyDef = BodyDef(type: BodyType.static)
//     ..position = Vector2.zero();
//   final body = world.createBody(bodyDef);
//   body.createFixture(fixtureDef);
//
//   final boundaryComponent = ShapeComponent(
//     shape: edgeShape,
//     paint: BasicPalette.green.paint(),
//   );
//   boundaryComponent.position = start;
//   add(boundaryComponent);
// }