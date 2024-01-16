import 'package:json_annotation/json_annotation.dart';

part '../generated/domain/todo_item.g.dart';

@JsonSerializable()
class TodoItem {
  final int id;
  final String title;
  final String content;
  final int category;
  final int secondsTimer;
  final int secondsStopwatch;
  final bool isDone;

  TodoItem({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.secondsTimer,
    required this.secondsStopwatch,
    required this.isDone,
  });

  factory TodoItem.fromJson(Map<String, dynamic> json) => _$TodoItemFromJson(json);

  Map<String, dynamic> toJson() => _$TodoItemToJson(this);
}
