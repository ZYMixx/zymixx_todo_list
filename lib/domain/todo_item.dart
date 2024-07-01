import 'package:get/get.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:zymixx_todo_list/data/tools/tool_date_formatter.dart';

part '../generated/domain/todo_item.g.dart';

@JsonSerializable()
class TodoItem {
  int id;
  String title;
  String content;
  String category;
  int timerSeconds;
  int stopwatchSeconds;
  int secondsSpent;
  int autoPauseSeconds;
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
    required this.secondsSpent,
    required this.autoPauseSeconds,
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
      secondsSpent: todoItem.secondsSpent,
      isDone: todoItem.isDone,
      targetDateTime: todoItem.targetDateTime,
      autoPauseSeconds: todoItem.autoPauseSeconds,
    );
  }

  factory TodoItem.fromJson(Map<String, dynamic> json) => _$TodoItemFromJson(json);

  Map<String, dynamic> toJson() => _$TodoItemToJson(this);

  @override
  String toString() {
    return 'TodoItem{id: $id, title: $title, content: $content, category $category, targetDateTime ${Get.find<ToolDateFormatter>().formatToMonthDay(targetDateTime)} }\n';
  }

  String toStringFull() {
    return 'TodoItem(id: $id, title: $title, content: $content, category: $category, '
        'timerSeconds: $timerSeconds, stopwatchSeconds: $stopwatchSeconds, '
        'secondsSpent: $secondsSpent, autoPauseSeconds: $autoPauseSeconds, '
        'isDone: $isDone, targetDateTime: ${targetDateTime?.toIso8601String()})\n';
  }

  TodoItem copyWith({
    int? id,
    String? title,
    String? content,
    String? category,
    int? timerSeconds,
    int? stopwatchSeconds,
    int? secondsSpent,
    bool? isDone,
    DateTime? targetDateTime,
    int? autoPauseSeconds,
  }) {
    return TodoItem(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      timerSeconds: timerSeconds ?? this.timerSeconds,
      stopwatchSeconds: stopwatchSeconds ?? this.stopwatchSeconds,
      isDone: isDone ?? this.isDone,
      secondsSpent: secondsSpent ?? this.secondsSpent,
      targetDateTime: targetDateTime ?? this.targetDateTime,
      autoPauseSeconds: autoPauseSeconds ?? this.autoPauseSeconds,
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
          secondsSpent == other.secondsSpent &&
          autoPauseSeconds == other.autoPauseSeconds &&
          targetDateTime == other.targetDateTime;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      content.hashCode ^
      category.hashCode ^
      timerSeconds.hashCode ^
      stopwatchSeconds.hashCode ^
      secondsSpent.hashCode ^
      autoPauseSeconds.hashCode ^
      isDone.hashCode ^
      targetDateTime.hashCode;
}
