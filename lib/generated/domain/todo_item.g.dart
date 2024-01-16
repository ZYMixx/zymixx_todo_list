// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../domain/todo_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TodoItem _$TodoItemFromJson(Map<String, dynamic> json) => TodoItem(
      id: json['id'] as int,
      title: json['title'] as String,
      content: json['content'] as String,
      category: json['category'] as int,
      secondsTimer: json['secondsTimer'] as int,
      secondsStopwatch: json['secondsStopwatch'] as int,
      isDone: json['isDone'] as bool,
    );

Map<String, dynamic> _$TodoItemToJson(TodoItem instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'content': instance.content,
      'category': instance.category,
      'secondsTimer': instance.secondsTimer,
      'secondsStopwatch': instance.secondsStopwatch,
      'isDone': instance.isDone,
    };
