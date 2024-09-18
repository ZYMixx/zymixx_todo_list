// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../domain/todo_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TodoItem _$TodoItemFromJson(Map<String, dynamic> json) => TodoItem(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      content: json['content'] as String,
      category: json['category'] as String,
      timerSeconds: (json['timerSeconds'] as num).toInt(),
      stopwatchSeconds: (json['stopwatchSeconds'] as num).toInt(),
      isDone: json['isDone'] as bool,
      secondsSpent: (json['secondsSpent'] as num).toInt(),
      autoPauseSeconds: (json['autoPauseSeconds'] as num).toInt(),
    targetDateTime: json['targetDateTime'] == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(json['targetDateTime'] ),
    );

Map<String, dynamic> _$TodoItemToJson(TodoItem instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'content': instance.content,
      'category': instance.category,
      'timerSeconds': instance.timerSeconds,
      'stopwatchSeconds': instance.stopwatchSeconds,
      'secondsSpent': instance.secondsSpent,
      'autoPauseSeconds': instance.autoPauseSeconds,
      'isDone': instance.isDone,
      'targetDateTime': instance.targetDateTime?.toIso8601String(),
    };
