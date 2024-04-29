// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../domain/todo_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TodoItem _$TodoItemFromJson(Map<String, dynamic> json) => TodoItem(
      id: json['id'] as int,
      title: json['title'] as String?,
      content: json['content'] as String?,
      category: json['category'] as String,
      timerSeconds: json['timerSeconds'] as int,
      stopwatchSeconds: json['stopwatchSeconds'] as int,
      isDone: json['isDone'] as bool,
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
      'isDone': instance.isDone,
      'targetDateTime': instance.targetDateTime?.toIso8601String(),
    };
