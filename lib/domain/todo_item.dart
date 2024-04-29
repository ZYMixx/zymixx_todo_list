import 'package:json_annotation/json_annotation.dart';

part '../generated/domain/todo_item.g.dart';

@JsonSerializable()
class TodoItem {
  int id;
  String? title;
  String? content;
  String category;
  int timerSeconds;
  int stopwatchSeconds;
  bool isDone;
  DateTime? targetDateTime;

  TodoItem({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.timerSeconds,
    required this.stopwatchSeconds,
    required this.isDone,
    this.targetDateTime,
  });

  factory TodoItem.duplicate({required TodoItem todoItem}) {
    return TodoItem(
      id: todoItem.id,
      title: todoItem.title,
      content: todoItem.content,
      category: todoItem.category,
      timerSeconds: todoItem.timerSeconds,
      stopwatchSeconds: todoItem.stopwatchSeconds,
      isDone: todoItem.isDone,
      targetDateTime: todoItem.targetDateTime,
    );
  }

  factory TodoItem.fromJson(Map<String, dynamic> json) => _$TodoItemFromJson(json);

  Map<String, dynamic> toJson() => _$TodoItemToJson(this);

  @override
  String toString() {
    return 'TodoItem{id: $id, title: $title, content: $content, category $category}';
  }

  TodoItem copyWith({
    int? id,
    String? title,
    String? content,
    String? category,
    int? timerSeconds,
    int? stopwatchSeconds,
    bool? isDone,
    DateTime? targetDateTime,
  }) {
    return TodoItem(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      timerSeconds: timerSeconds ?? this.timerSeconds,
      stopwatchSeconds: stopwatchSeconds ?? this.stopwatchSeconds,
      isDone: isDone ?? this.isDone,
      targetDateTime: targetDateTime ?? this.targetDateTime,
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
          isDone == other.isDone &&
          targetDateTime == other.targetDateTime;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      content.hashCode ^
      category.hashCode ^
      timerSeconds.hashCode ^
      stopwatchSeconds.hashCode ^
      isDone.hashCode ^
      targetDateTime.hashCode;

// @override
  // bool operator ==(Object other) =>
  //     identical(this, other) ||
  //     other is TodoItem &&
  //         runtimeType == other.runtimeType &&
  //         id == other.id &&
  //         title == other.title &&
  //         content == other.content &&
  //         category == other.category &&
  //         timerSeconds == other.timerSeconds &&
  //         stopwatchSeconds == other.stopwatchSeconds &&
  //         isDone == other.isDone;
  //
  // @override
  // int get hashCode =>
  //     id.hashCode ^
  //     title.hashCode ^
  //     content.hashCode ^
  //     category.hashCode ^
  //     timerSeconds.hashCode ^
  //     stopwatchSeconds.hashCode ^
  //     isDone.hashCode;
}

//      targetDateTime: json['targetDateTime'] == null
//           ? null
//           : DateTime.fromMillisecondsSinceEpoch(json['targetDateTime']),