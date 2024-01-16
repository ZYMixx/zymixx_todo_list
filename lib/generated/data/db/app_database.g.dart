// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../../data/db/app_database.dart';

// ignore_for_file: type=lint
class $TodoItemDBTable extends TodoItemDB
    with TableInfo<$TodoItemDBTable, TodoItemDBData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TodoItemDBTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 6, maxTextLength: 32),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _contentMeta =
      const VerificationMeta('content');
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'body', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<int> category = GeneratedColumn<int>(
      'category', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _secondsTimerMeta =
      const VerificationMeta('secondsTimer');
  @override
  late final GeneratedColumn<int> secondsTimer = GeneratedColumn<int>(
      'seconds_timer', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _secondsStopwatchMeta =
      const VerificationMeta('secondsStopwatch');
  @override
  late final GeneratedColumn<int> secondsStopwatch = GeneratedColumn<int>(
      'seconds_stopwatch', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _isDoneMeta = const VerificationMeta('isDone');
  @override
  late final GeneratedColumn<bool> isDone = GeneratedColumn<bool>(
      'is_done', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_done" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns =>
      [id, title, content, category, secondsTimer, secondsStopwatch, isDone];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'todo_item_d_b';
  @override
  VerificationContext validateIntegrity(Insertable<TodoItemDBData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('body')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['body']!, _contentMeta));
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    }
    if (data.containsKey('seconds_timer')) {
      context.handle(
          _secondsTimerMeta,
          secondsTimer.isAcceptableOrUnknown(
              data['seconds_timer']!, _secondsTimerMeta));
    }
    if (data.containsKey('seconds_stopwatch')) {
      context.handle(
          _secondsStopwatchMeta,
          secondsStopwatch.isAcceptableOrUnknown(
              data['seconds_stopwatch']!, _secondsStopwatchMeta));
    }
    if (data.containsKey('is_done')) {
      context.handle(_isDoneMeta,
          isDone.isAcceptableOrUnknown(data['is_done']!, _isDoneMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TodoItemDBData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TodoItemDBData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}body'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}category']),
      secondsTimer: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}seconds_timer']),
      secondsStopwatch: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}seconds_stopwatch']),
      isDone: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_done'])!,
    );
  }

  @override
  $TodoItemDBTable createAlias(String alias) {
    return $TodoItemDBTable(attachedDatabase, alias);
  }
}

class TodoItemDBData extends DataClass implements Insertable<TodoItemDBData> {
  final int id;
  final String title;
  final String content;
  final int? category;
  final int? secondsTimer;
  final int? secondsStopwatch;
  final bool isDone;
  const TodoItemDBData(
      {required this.id,
      required this.title,
      required this.content,
      this.category,
      this.secondsTimer,
      this.secondsStopwatch,
      required this.isDone});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['body'] = Variable<String>(content);
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<int>(category);
    }
    if (!nullToAbsent || secondsTimer != null) {
      map['seconds_timer'] = Variable<int>(secondsTimer);
    }
    if (!nullToAbsent || secondsStopwatch != null) {
      map['seconds_stopwatch'] = Variable<int>(secondsStopwatch);
    }
    map['is_done'] = Variable<bool>(isDone);
    return map;
  }

  TodoItemDBCompanion toCompanion(bool nullToAbsent) {
    return TodoItemDBCompanion(
      id: Value(id),
      title: Value(title),
      content: Value(content),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      secondsTimer: secondsTimer == null && nullToAbsent
          ? const Value.absent()
          : Value(secondsTimer),
      secondsStopwatch: secondsStopwatch == null && nullToAbsent
          ? const Value.absent()
          : Value(secondsStopwatch),
      isDone: Value(isDone),
    );
  }

  factory TodoItemDBData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TodoItemDBData(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      content: serializer.fromJson<String>(json['content']),
      category: serializer.fromJson<int?>(json['category']),
      secondsTimer: serializer.fromJson<int?>(json['secondsTimer']),
      secondsStopwatch: serializer.fromJson<int?>(json['secondsStopwatch']),
      isDone: serializer.fromJson<bool>(json['isDone']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'content': serializer.toJson<String>(content),
      'category': serializer.toJson<int?>(category),
      'secondsTimer': serializer.toJson<int?>(secondsTimer),
      'secondsStopwatch': serializer.toJson<int?>(secondsStopwatch),
      'isDone': serializer.toJson<bool>(isDone),
    };
  }

  TodoItemDBData copyWith(
          {int? id,
          String? title,
          String? content,
          Value<int?> category = const Value.absent(),
          Value<int?> secondsTimer = const Value.absent(),
          Value<int?> secondsStopwatch = const Value.absent(),
          bool? isDone}) =>
      TodoItemDBData(
        id: id ?? this.id,
        title: title ?? this.title,
        content: content ?? this.content,
        category: category.present ? category.value : this.category,
        secondsTimer:
            secondsTimer.present ? secondsTimer.value : this.secondsTimer,
        secondsStopwatch: secondsStopwatch.present
            ? secondsStopwatch.value
            : this.secondsStopwatch,
        isDone: isDone ?? this.isDone,
      );
  @override
  String toString() {
    return (StringBuffer('TodoItemDBData(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('content: $content, ')
          ..write('category: $category, ')
          ..write('secondsTimer: $secondsTimer, ')
          ..write('secondsStopwatch: $secondsStopwatch, ')
          ..write('isDone: $isDone')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, title, content, category, secondsTimer, secondsStopwatch, isDone);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TodoItemDBData &&
          other.id == this.id &&
          other.title == this.title &&
          other.content == this.content &&
          other.category == this.category &&
          other.secondsTimer == this.secondsTimer &&
          other.secondsStopwatch == this.secondsStopwatch &&
          other.isDone == this.isDone);
}

class TodoItemDBCompanion extends UpdateCompanion<TodoItemDBData> {
  final Value<int> id;
  final Value<String> title;
  final Value<String> content;
  final Value<int?> category;
  final Value<int?> secondsTimer;
  final Value<int?> secondsStopwatch;
  final Value<bool> isDone;
  const TodoItemDBCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.content = const Value.absent(),
    this.category = const Value.absent(),
    this.secondsTimer = const Value.absent(),
    this.secondsStopwatch = const Value.absent(),
    this.isDone = const Value.absent(),
  });
  TodoItemDBCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    required String content,
    this.category = const Value.absent(),
    this.secondsTimer = const Value.absent(),
    this.secondsStopwatch = const Value.absent(),
    this.isDone = const Value.absent(),
  })  : title = Value(title),
        content = Value(content);
  static Insertable<TodoItemDBData> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? content,
    Expression<int>? category,
    Expression<int>? secondsTimer,
    Expression<int>? secondsStopwatch,
    Expression<bool>? isDone,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (content != null) 'body': content,
      if (category != null) 'category': category,
      if (secondsTimer != null) 'seconds_timer': secondsTimer,
      if (secondsStopwatch != null) 'seconds_stopwatch': secondsStopwatch,
      if (isDone != null) 'is_done': isDone,
    });
  }

  TodoItemDBCompanion copyWith(
      {Value<int>? id,
      Value<String>? title,
      Value<String>? content,
      Value<int?>? category,
      Value<int?>? secondsTimer,
      Value<int?>? secondsStopwatch,
      Value<bool>? isDone}) {
    return TodoItemDBCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      secondsTimer: secondsTimer ?? this.secondsTimer,
      secondsStopwatch: secondsStopwatch ?? this.secondsStopwatch,
      isDone: isDone ?? this.isDone,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (content.present) {
      map['body'] = Variable<String>(content.value);
    }
    if (category.present) {
      map['category'] = Variable<int>(category.value);
    }
    if (secondsTimer.present) {
      map['seconds_timer'] = Variable<int>(secondsTimer.value);
    }
    if (secondsStopwatch.present) {
      map['seconds_stopwatch'] = Variable<int>(secondsStopwatch.value);
    }
    if (isDone.present) {
      map['is_done'] = Variable<bool>(isDone.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TodoItemDBCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('content: $content, ')
          ..write('category: $category, ')
          ..write('secondsTimer: $secondsTimer, ')
          ..write('secondsStopwatch: $secondsStopwatch, ')
          ..write('isDone: $isDone')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  late final $TodoItemDBTable todoItemDB = $TodoItemDBTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [todoItemDB];
}
