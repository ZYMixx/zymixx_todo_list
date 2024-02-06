import 'package:json_annotation/json_annotation.dart';

part '../generated/domain/todo_item.g.dart';

@JsonSerializable()
class TodoItem {
  int id;
  String? title;
  String? content;
  int category;
  int timerSeconds;
  int stopwatchSeconds;
  bool isDone;

  TodoItem({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.timerSeconds,
    required this.stopwatchSeconds,
    required this.isDone,
  });

  factory TodoItem.fromJson(Map<String, dynamic> json) => _$TodoItemFromJson(json);

  Map<String, dynamic> toJson() => _$TodoItemToJson(this);

  @override
  String toString() {
    return 'TodoItem{id: $id, title: $title, content: $content}';
  }

  TodoItem copyWith({
    int? id,
    String? title,
    String? content,
    int? category,
    int? timerSeconds,
    int? stopwatchSeconds,
    bool? isDone,
  }) {
    return TodoItem(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      timerSeconds: timerSeconds ?? this.timerSeconds,
      stopwatchSeconds: stopwatchSeconds ?? this.stopwatchSeconds,
      isDone: isDone ?? this.isDone,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodoItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          content == other.content &&
          category == other.category &&
          timerSeconds == other.timerSeconds &&
          stopwatchSeconds == other.stopwatchSeconds &&
          isDone == other.isDone;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      content.hashCode ^
      category.hashCode ^
      timerSeconds.hashCode ^
      stopwatchSeconds.hashCode ^
      isDone.hashCode;
}
