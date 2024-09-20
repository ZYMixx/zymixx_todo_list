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
      'id', aliasedName, true,
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
          GeneratedColumn.checkTextLength(minTextLength: 6, maxTextLength: 60),
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
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('active'));
  static const VerificationMeta _timerSecondsMeta =
      const VerificationMeta('timerSeconds');
  @override
  late final GeneratedColumn<int> timerSeconds = GeneratedColumn<int>(
      'timer_seconds', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _stopwatchSecondsMeta =
      const VerificationMeta('stopwatchSeconds');
  @override
  late final GeneratedColumn<int> stopwatchSeconds = GeneratedColumn<int>(
      'stopwatch_seconds', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _secondsSpentMeta =
      const VerificationMeta('secondsSpent');
  @override
  late final GeneratedColumn<int> secondsSpent = GeneratedColumn<int>(
      'seconds_spent', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _autoPauseSecondsMeta =
      const VerificationMeta('autoPauseSeconds');
  @override
  late final GeneratedColumn<int> autoPauseSeconds = GeneratedColumn<int>(
      'auto_pause_seconds', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _isDoneMeta = const VerificationMeta('isDone');
  @override
  late final GeneratedColumn<bool> isDone = GeneratedColumn<bool>(
      'is_done', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_done" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _targetDateTimeMeta =
      const VerificationMeta('targetDateTime');
  @override
  late final GeneratedColumn<DateTime> targetDateTime =
      GeneratedColumn<DateTime>('target_date_time', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        title,
        content,
        category,
        timerSeconds,
        stopwatchSeconds,
        secondsSpent,
        autoPauseSeconds,
        isDone,
        targetDateTime
      ];
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
    if (data.containsKey('timer_seconds')) {
      context.handle(
          _timerSecondsMeta,
          timerSeconds.isAcceptableOrUnknown(
              data['timer_seconds']!, _timerSecondsMeta));
    }
    if (data.containsKey('stopwatch_seconds')) {
      context.handle(
          _stopwatchSecondsMeta,
          stopwatchSeconds.isAcceptableOrUnknown(
              data['stopwatch_seconds']!, _stopwatchSecondsMeta));
    }
    if (data.containsKey('seconds_spent')) {
      context.handle(
          _secondsSpentMeta,
          secondsSpent.isAcceptableOrUnknown(
              data['seconds_spent']!, _secondsSpentMeta));
    }
    if (data.containsKey('auto_pause_seconds')) {
      context.handle(
          _autoPauseSecondsMeta,
          autoPauseSeconds.isAcceptableOrUnknown(
              data['auto_pause_seconds']!, _autoPauseSecondsMeta));
    }
    if (data.containsKey('is_done')) {
      context.handle(_isDoneMeta,
          isDone.isAcceptableOrUnknown(data['is_done']!, _isDoneMeta));
    }
    if (data.containsKey('target_date_time')) {
      context.handle(
          _targetDateTimeMeta,
          targetDateTime.isAcceptableOrUnknown(
              data['target_date_time']!, _targetDateTimeMeta));
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
          .read(DriftSqlType.int, data['${effectivePrefix}id']),
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}body'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      timerSeconds: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}timer_seconds'])!,
      stopwatchSeconds: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}stopwatch_seconds'])!,
      secondsSpent: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}seconds_spent']),
      autoPauseSeconds: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}auto_pause_seconds']),
      isDone: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_done'])!,
      targetDateTime: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}target_date_time']),
    );
  }

  @override
  $TodoItemDBTable createAlias(String alias) {
    return $TodoItemDBTable(attachedDatabase, alias);
  }
}

class TodoItemDBData extends DataClass implements Insertable<TodoItemDBData> {
  final int? id;
  final String title;
  final String content;
  final String category;
  final int timerSeconds;
  final int stopwatchSeconds;
  final int? secondsSpent;
  final int? autoPauseSeconds;
  final bool isDone;
  final DateTime? targetDateTime;
  const TodoItemDBData(
      {this.id,
      required this.title,
      required this.content,
      required this.category,
      required this.timerSeconds,
      required this.stopwatchSeconds,
      this.secondsSpent,
      this.autoPauseSeconds,
      required this.isDone,
      this.targetDateTime});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || id != null) {
      map['id'] = Variable<int>(id);
    }
    map['title'] = Variable<String>(title);
    map['body'] = Variable<String>(content);
    map['category'] = Variable<String>(category);
    map['timer_seconds'] = Variable<int>(timerSeconds);
    map['stopwatch_seconds'] = Variable<int>(stopwatchSeconds);
    if (!nullToAbsent || secondsSpent != null) {
      map['seconds_spent'] = Variable<int>(secondsSpent);
    }
    if (!nullToAbsent || autoPauseSeconds != null) {
      map['auto_pause_seconds'] = Variable<int>(autoPauseSeconds);
    }
    map['is_done'] = Variable<bool>(isDone);
    if (!nullToAbsent || targetDateTime != null) {
      map['target_date_time'] = Variable<DateTime>(targetDateTime);
    }
    return map;
  }

  TodoItemDBCompanion toCompanion(bool nullToAbsent) {
    return TodoItemDBCompanion(
      id: id == null && nullToAbsent ? const Value.absent() : Value(id),
      title: Value(title),
      content: Value(content),
      category: Value(category),
      timerSeconds: Value(timerSeconds),
      stopwatchSeconds: Value(stopwatchSeconds),
      secondsSpent: secondsSpent == null && nullToAbsent
          ? const Value.absent()
          : Value(secondsSpent),
      autoPauseSeconds: autoPauseSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(autoPauseSeconds),
      isDone: Value(isDone),
      targetDateTime: targetDateTime == null && nullToAbsent
          ? const Value.absent()
          : Value(targetDateTime),
    );
  }

  factory TodoItemDBData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TodoItemDBData(
      id: serializer.fromJson<int?>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      content: serializer.fromJson<String>(json['content']),
      category: serializer.fromJson<String>(json['category']),
      timerSeconds: serializer.fromJson<int>(json['timerSeconds']),
      stopwatchSeconds: serializer.fromJson<int>(json['stopwatchSeconds']),
      secondsSpent: serializer.fromJson<int?>(json['secondsSpent']),
      autoPauseSeconds: serializer.fromJson<int?>(json['autoPauseSeconds']),
      isDone: serializer.fromJson<bool>(json['isDone']),
      targetDateTime: serializer.fromJson<DateTime?>(json['targetDateTime']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int?>(id),
      'title': serializer.toJson<String>(title),
      'content': serializer.toJson<String>(content),
      'category': serializer.toJson<String>(category),
      'timerSeconds': serializer.toJson<int>(timerSeconds),
      'stopwatchSeconds': serializer.toJson<int>(stopwatchSeconds),
      'secondsSpent': serializer.toJson<int?>(secondsSpent),
      'autoPauseSeconds': serializer.toJson<int?>(autoPauseSeconds),
      'isDone': serializer.toJson<bool>(isDone),
      'targetDateTime': serializer.toJson<DateTime?>(targetDateTime),
    };
  }

  TodoItemDBData copyWith(
          {Value<int?> id = const Value.absent(),
          String? title,
          String? content,
          String? category,
          int? timerSeconds,
          int? stopwatchSeconds,
          Value<int?> secondsSpent = const Value.absent(),
          Value<int?> autoPauseSeconds = const Value.absent(),
          bool? isDone,
          Value<DateTime?> targetDateTime = const Value.absent()}) =>
      TodoItemDBData(
        id: id.present ? id.value : this.id,
        title: title ?? this.title,
        content: content ?? this.content,
        category: category ?? this.category,
        timerSeconds: timerSeconds ?? this.timerSeconds,
        stopwatchSeconds: stopwatchSeconds ?? this.stopwatchSeconds,
        secondsSpent:
            secondsSpent.present ? secondsSpent.value : this.secondsSpent,
        autoPauseSeconds: autoPauseSeconds.present
            ? autoPauseSeconds.value
            : this.autoPauseSeconds,
        isDone: isDone ?? this.isDone,
        targetDateTime:
            targetDateTime.present ? targetDateTime.value : this.targetDateTime,
      );
  TodoItemDBData copyWithCompanion(TodoItemDBCompanion data) {
    return TodoItemDBData(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      content: data.content.present ? data.content.value : this.content,
      category: data.category.present ? data.category.value : this.category,
      timerSeconds: data.timerSeconds.present
          ? data.timerSeconds.value
          : this.timerSeconds,
      stopwatchSeconds: data.stopwatchSeconds.present
          ? data.stopwatchSeconds.value
          : this.stopwatchSeconds,
      secondsSpent: data.secondsSpent.present
          ? data.secondsSpent.value
          : this.secondsSpent,
      autoPauseSeconds: data.autoPauseSeconds.present
          ? data.autoPauseSeconds.value
          : this.autoPauseSeconds,
      isDone: data.isDone.present ? data.isDone.value : this.isDone,
      targetDateTime: data.targetDateTime.present
          ? data.targetDateTime.value
          : this.targetDateTime,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TodoItemDBData(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('content: $content, ')
          ..write('category: $category, ')
          ..write('timerSeconds: $timerSeconds, ')
          ..write('stopwatchSeconds: $stopwatchSeconds, ')
          ..write('secondsSpent: $secondsSpent, ')
          ..write('autoPauseSeconds: $autoPauseSeconds, ')
          ..write('isDone: $isDone, ')
          ..write('targetDateTime: $targetDateTime')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, content, category, timerSeconds,
      stopwatchSeconds, secondsSpent, autoPauseSeconds, isDone, targetDateTime);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TodoItemDBData &&
          other.id == this.id &&
          other.title == this.title &&
          other.content == this.content &&
          other.category == this.category &&
          other.timerSeconds == this.timerSeconds &&
          other.stopwatchSeconds == this.stopwatchSeconds &&
          other.secondsSpent == this.secondsSpent &&
          other.autoPauseSeconds == this.autoPauseSeconds &&
          other.isDone == this.isDone &&
          other.targetDateTime == this.targetDateTime);
}

class TodoItemDBCompanion extends UpdateCompanion<TodoItemDBData> {
  final Value<int?> id;
  final Value<String> title;
  final Value<String> content;
  final Value<String> category;
  final Value<int> timerSeconds;
  final Value<int> stopwatchSeconds;
  final Value<int?> secondsSpent;
  final Value<int?> autoPauseSeconds;
  final Value<bool> isDone;
  final Value<DateTime?> targetDateTime;
  const TodoItemDBCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.content = const Value.absent(),
    this.category = const Value.absent(),
    this.timerSeconds = const Value.absent(),
    this.stopwatchSeconds = const Value.absent(),
    this.secondsSpent = const Value.absent(),
    this.autoPauseSeconds = const Value.absent(),
    this.isDone = const Value.absent(),
    this.targetDateTime = const Value.absent(),
  });
  TodoItemDBCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    required String content,
    this.category = const Value.absent(),
    this.timerSeconds = const Value.absent(),
    this.stopwatchSeconds = const Value.absent(),
    this.secondsSpent = const Value.absent(),
    this.autoPauseSeconds = const Value.absent(),
    this.isDone = const Value.absent(),
    this.targetDateTime = const Value.absent(),
  })  : title = Value(title),
        content = Value(content);
  static Insertable<TodoItemDBData> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? content,
    Expression<String>? category,
    Expression<int>? timerSeconds,
    Expression<int>? stopwatchSeconds,
    Expression<int>? secondsSpent,
    Expression<int>? autoPauseSeconds,
    Expression<bool>? isDone,
    Expression<DateTime>? targetDateTime,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (content != null) 'body': content,
      if (category != null) 'category': category,
      if (timerSeconds != null) 'timer_seconds': timerSeconds,
      if (stopwatchSeconds != null) 'stopwatch_seconds': stopwatchSeconds,
      if (secondsSpent != null) 'seconds_spent': secondsSpent,
      if (autoPauseSeconds != null) 'auto_pause_seconds': autoPauseSeconds,
      if (isDone != null) 'is_done': isDone,
      if (targetDateTime != null) 'target_date_time': targetDateTime,
    });
  }

  TodoItemDBCompanion copyWith(
      {Value<int?>? id,
      Value<String>? title,
      Value<String>? content,
      Value<String>? category,
      Value<int>? timerSeconds,
      Value<int>? stopwatchSeconds,
      Value<int?>? secondsSpent,
      Value<int?>? autoPauseSeconds,
      Value<bool>? isDone,
      Value<DateTime?>? targetDateTime}) {
    return TodoItemDBCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      timerSeconds: timerSeconds ?? this.timerSeconds,
      stopwatchSeconds: stopwatchSeconds ?? this.stopwatchSeconds,
      secondsSpent: secondsSpent ?? this.secondsSpent,
      autoPauseSeconds: autoPauseSeconds ?? this.autoPauseSeconds,
      isDone: isDone ?? this.isDone,
      targetDateTime: targetDateTime ?? this.targetDateTime,
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
      map['category'] = Variable<String>(category.value);
    }
    if (timerSeconds.present) {
      map['timer_seconds'] = Variable<int>(timerSeconds.value);
    }
    if (stopwatchSeconds.present) {
      map['stopwatch_seconds'] = Variable<int>(stopwatchSeconds.value);
    }
    if (secondsSpent.present) {
      map['seconds_spent'] = Variable<int>(secondsSpent.value);
    }
    if (autoPauseSeconds.present) {
      map['auto_pause_seconds'] = Variable<int>(autoPauseSeconds.value);
    }
    if (isDone.present) {
      map['is_done'] = Variable<bool>(isDone.value);
    }
    if (targetDateTime.present) {
      map['target_date_time'] = Variable<DateTime>(targetDateTime.value);
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
          ..write('timerSeconds: $timerSeconds, ')
          ..write('stopwatchSeconds: $stopwatchSeconds, ')
          ..write('secondsSpent: $secondsSpent, ')
          ..write('autoPauseSeconds: $autoPauseSeconds, ')
          ..write('isDone: $isDone, ')
          ..write('targetDateTime: $targetDateTime')
          ..write(')'))
        .toString();
  }
}

class $WorkOnSideTodoItemDBTable extends WorkOnSideTodoItemDB
    with TableInfo<$WorkOnSideTodoItemDBTable, WorkOnSideTodoItemDBData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkOnSideTodoItemDBTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, true,
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
          GeneratedColumn.checkTextLength(minTextLength: 6, maxTextLength: 60),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _secondsSpentMeta =
      const VerificationMeta('secondsSpent');
  @override
  late final GeneratedColumn<int> secondsSpent = GeneratedColumn<int>(
      'seconds_spent', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _feelingScoreMeta =
      const VerificationMeta('feelingScore');
  @override
  late final GeneratedColumn<int> feelingScore = GeneratedColumn<int>(
      'feeling_score', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _usefulScoreMeta =
      const VerificationMeta('usefulScore');
  @override
  late final GeneratedColumn<int> usefulScore = GeneratedColumn<int>(
      'useful_score', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _targetDateTimeMeta =
      const VerificationMeta('targetDateTime');
  @override
  late final GeneratedColumn<DateTime> targetDateTime =
      GeneratedColumn<DateTime>('target_date_time', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, title, secondsSpent, feelingScore, usefulScore, targetDateTime];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'work_on_side_todo_item_d_b';
  @override
  VerificationContext validateIntegrity(
      Insertable<WorkOnSideTodoItemDBData> instance,
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
    if (data.containsKey('seconds_spent')) {
      context.handle(
          _secondsSpentMeta,
          secondsSpent.isAcceptableOrUnknown(
              data['seconds_spent']!, _secondsSpentMeta));
    }
    if (data.containsKey('feeling_score')) {
      context.handle(
          _feelingScoreMeta,
          feelingScore.isAcceptableOrUnknown(
              data['feeling_score']!, _feelingScoreMeta));
    }
    if (data.containsKey('useful_score')) {
      context.handle(
          _usefulScoreMeta,
          usefulScore.isAcceptableOrUnknown(
              data['useful_score']!, _usefulScoreMeta));
    }
    if (data.containsKey('target_date_time')) {
      context.handle(
          _targetDateTimeMeta,
          targetDateTime.isAcceptableOrUnknown(
              data['target_date_time']!, _targetDateTimeMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkOnSideTodoItemDBData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkOnSideTodoItemDBData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id']),
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      secondsSpent: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}seconds_spent']),
      feelingScore: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}feeling_score']),
      usefulScore: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}useful_score']),
      targetDateTime: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}target_date_time']),
    );
  }

  @override
  $WorkOnSideTodoItemDBTable createAlias(String alias) {
    return $WorkOnSideTodoItemDBTable(attachedDatabase, alias);
  }
}

class WorkOnSideTodoItemDBData extends DataClass
    implements Insertable<WorkOnSideTodoItemDBData> {
  final int? id;
  final String title;
  final int? secondsSpent;
  final int? feelingScore;
  final int? usefulScore;
  final DateTime? targetDateTime;
  const WorkOnSideTodoItemDBData(
      {this.id,
      required this.title,
      this.secondsSpent,
      this.feelingScore,
      this.usefulScore,
      this.targetDateTime});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || id != null) {
      map['id'] = Variable<int>(id);
    }
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || secondsSpent != null) {
      map['seconds_spent'] = Variable<int>(secondsSpent);
    }
    if (!nullToAbsent || feelingScore != null) {
      map['feeling_score'] = Variable<int>(feelingScore);
    }
    if (!nullToAbsent || usefulScore != null) {
      map['useful_score'] = Variable<int>(usefulScore);
    }
    if (!nullToAbsent || targetDateTime != null) {
      map['target_date_time'] = Variable<DateTime>(targetDateTime);
    }
    return map;
  }

  WorkOnSideTodoItemDBCompanion toCompanion(bool nullToAbsent) {
    return WorkOnSideTodoItemDBCompanion(
      id: id == null && nullToAbsent ? const Value.absent() : Value(id),
      title: Value(title),
      secondsSpent: secondsSpent == null && nullToAbsent
          ? const Value.absent()
          : Value(secondsSpent),
      feelingScore: feelingScore == null && nullToAbsent
          ? const Value.absent()
          : Value(feelingScore),
      usefulScore: usefulScore == null && nullToAbsent
          ? const Value.absent()
          : Value(usefulScore),
      targetDateTime: targetDateTime == null && nullToAbsent
          ? const Value.absent()
          : Value(targetDateTime),
    );
  }

  factory WorkOnSideTodoItemDBData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkOnSideTodoItemDBData(
      id: serializer.fromJson<int?>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      secondsSpent: serializer.fromJson<int?>(json['secondsSpent']),
      feelingScore: serializer.fromJson<int?>(json['feelingScore']),
      usefulScore: serializer.fromJson<int?>(json['usefulScore']),
      targetDateTime: serializer.fromJson<DateTime?>(json['targetDateTime']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int?>(id),
      'title': serializer.toJson<String>(title),
      'secondsSpent': serializer.toJson<int?>(secondsSpent),
      'feelingScore': serializer.toJson<int?>(feelingScore),
      'usefulScore': serializer.toJson<int?>(usefulScore),
      'targetDateTime': serializer.toJson<DateTime?>(targetDateTime),
    };
  }

  WorkOnSideTodoItemDBData copyWith(
          {Value<int?> id = const Value.absent(),
          String? title,
          Value<int?> secondsSpent = const Value.absent(),
          Value<int?> feelingScore = const Value.absent(),
          Value<int?> usefulScore = const Value.absent(),
          Value<DateTime?> targetDateTime = const Value.absent()}) =>
      WorkOnSideTodoItemDBData(
        id: id.present ? id.value : this.id,
        title: title ?? this.title,
        secondsSpent:
            secondsSpent.present ? secondsSpent.value : this.secondsSpent,
        feelingScore:
            feelingScore.present ? feelingScore.value : this.feelingScore,
        usefulScore: usefulScore.present ? usefulScore.value : this.usefulScore,
        targetDateTime:
            targetDateTime.present ? targetDateTime.value : this.targetDateTime,
      );
  WorkOnSideTodoItemDBData copyWithCompanion(
      WorkOnSideTodoItemDBCompanion data) {
    return WorkOnSideTodoItemDBData(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      secondsSpent: data.secondsSpent.present
          ? data.secondsSpent.value
          : this.secondsSpent,
      feelingScore: data.feelingScore.present
          ? data.feelingScore.value
          : this.feelingScore,
      usefulScore:
          data.usefulScore.present ? data.usefulScore.value : this.usefulScore,
      targetDateTime: data.targetDateTime.present
          ? data.targetDateTime.value
          : this.targetDateTime,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkOnSideTodoItemDBData(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('secondsSpent: $secondsSpent, ')
          ..write('feelingScore: $feelingScore, ')
          ..write('usefulScore: $usefulScore, ')
          ..write('targetDateTime: $targetDateTime')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, title, secondsSpent, feelingScore, usefulScore, targetDateTime);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkOnSideTodoItemDBData &&
          other.id == this.id &&
          other.title == this.title &&
          other.secondsSpent == this.secondsSpent &&
          other.feelingScore == this.feelingScore &&
          other.usefulScore == this.usefulScore &&
          other.targetDateTime == this.targetDateTime);
}

class WorkOnSideTodoItemDBCompanion
    extends UpdateCompanion<WorkOnSideTodoItemDBData> {
  final Value<int?> id;
  final Value<String> title;
  final Value<int?> secondsSpent;
  final Value<int?> feelingScore;
  final Value<int?> usefulScore;
  final Value<DateTime?> targetDateTime;
  const WorkOnSideTodoItemDBCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.secondsSpent = const Value.absent(),
    this.feelingScore = const Value.absent(),
    this.usefulScore = const Value.absent(),
    this.targetDateTime = const Value.absent(),
  });
  WorkOnSideTodoItemDBCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    this.secondsSpent = const Value.absent(),
    this.feelingScore = const Value.absent(),
    this.usefulScore = const Value.absent(),
    this.targetDateTime = const Value.absent(),
  }) : title = Value(title);
  static Insertable<WorkOnSideTodoItemDBData> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<int>? secondsSpent,
    Expression<int>? feelingScore,
    Expression<int>? usefulScore,
    Expression<DateTime>? targetDateTime,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (secondsSpent != null) 'seconds_spent': secondsSpent,
      if (feelingScore != null) 'feeling_score': feelingScore,
      if (usefulScore != null) 'useful_score': usefulScore,
      if (targetDateTime != null) 'target_date_time': targetDateTime,
    });
  }

  WorkOnSideTodoItemDBCompanion copyWith(
      {Value<int?>? id,
      Value<String>? title,
      Value<int?>? secondsSpent,
      Value<int?>? feelingScore,
      Value<int?>? usefulScore,
      Value<DateTime?>? targetDateTime}) {
    return WorkOnSideTodoItemDBCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      secondsSpent: secondsSpent ?? this.secondsSpent,
      feelingScore: feelingScore ?? this.feelingScore,
      usefulScore: usefulScore ?? this.usefulScore,
      targetDateTime: targetDateTime ?? this.targetDateTime,
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
    if (secondsSpent.present) {
      map['seconds_spent'] = Variable<int>(secondsSpent.value);
    }
    if (feelingScore.present) {
      map['feeling_score'] = Variable<int>(feelingScore.value);
    }
    if (usefulScore.present) {
      map['useful_score'] = Variable<int>(usefulScore.value);
    }
    if (targetDateTime.present) {
      map['target_date_time'] = Variable<DateTime>(targetDateTime.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkOnSideTodoItemDBCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('secondsSpent: $secondsSpent, ')
          ..write('feelingScore: $feelingScore, ')
          ..write('usefulScore: $usefulScore, ')
          ..write('targetDateTime: $targetDateTime')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TodoItemDBTable todoItemDB = $TodoItemDBTable(this);
  late final $WorkOnSideTodoItemDBTable workOnSideTodoItemDB =
      $WorkOnSideTodoItemDBTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [todoItemDB, workOnSideTodoItemDB];
}

typedef $$TodoItemDBTableCreateCompanionBuilder = TodoItemDBCompanion Function({
  Value<int?> id,
  required String title,
  required String content,
  Value<String> category,
  Value<int> timerSeconds,
  Value<int> stopwatchSeconds,
  Value<int?> secondsSpent,
  Value<int?> autoPauseSeconds,
  Value<bool> isDone,
  Value<DateTime?> targetDateTime,
});
typedef $$TodoItemDBTableUpdateCompanionBuilder = TodoItemDBCompanion Function({
  Value<int?> id,
  Value<String> title,
  Value<String> content,
  Value<String> category,
  Value<int> timerSeconds,
  Value<int> stopwatchSeconds,
  Value<int?> secondsSpent,
  Value<int?> autoPauseSeconds,
  Value<bool> isDone,
  Value<DateTime?> targetDateTime,
});

class $$TodoItemDBTableFilterComposer
    extends FilterComposer<_$AppDatabase, $TodoItemDBTable> {
  $$TodoItemDBTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get title => $state.composableBuilder(
      column: $state.table.title,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get content => $state.composableBuilder(
      column: $state.table.content,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get category => $state.composableBuilder(
      column: $state.table.category,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get timerSeconds => $state.composableBuilder(
      column: $state.table.timerSeconds,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get stopwatchSeconds => $state.composableBuilder(
      column: $state.table.stopwatchSeconds,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get secondsSpent => $state.composableBuilder(
      column: $state.table.secondsSpent,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get autoPauseSeconds => $state.composableBuilder(
      column: $state.table.autoPauseSeconds,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get isDone => $state.composableBuilder(
      column: $state.table.isDone,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get targetDateTime => $state.composableBuilder(
      column: $state.table.targetDateTime,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$TodoItemDBTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $TodoItemDBTable> {
  $$TodoItemDBTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get title => $state.composableBuilder(
      column: $state.table.title,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get content => $state.composableBuilder(
      column: $state.table.content,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get category => $state.composableBuilder(
      column: $state.table.category,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get timerSeconds => $state.composableBuilder(
      column: $state.table.timerSeconds,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get stopwatchSeconds => $state.composableBuilder(
      column: $state.table.stopwatchSeconds,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get secondsSpent => $state.composableBuilder(
      column: $state.table.secondsSpent,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get autoPauseSeconds => $state.composableBuilder(
      column: $state.table.autoPauseSeconds,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get isDone => $state.composableBuilder(
      column: $state.table.isDone,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get targetDateTime => $state.composableBuilder(
      column: $state.table.targetDateTime,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

class $$TodoItemDBTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TodoItemDBTable,
    TodoItemDBData,
    $$TodoItemDBTableFilterComposer,
    $$TodoItemDBTableOrderingComposer,
    $$TodoItemDBTableCreateCompanionBuilder,
    $$TodoItemDBTableUpdateCompanionBuilder,
    (
      TodoItemDBData,
      BaseReferences<_$AppDatabase, $TodoItemDBTable, TodoItemDBData>
    ),
    TodoItemDBData,
    PrefetchHooks Function()> {
  $$TodoItemDBTableTableManager(_$AppDatabase db, $TodoItemDBTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$TodoItemDBTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$TodoItemDBTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int?> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> content = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<int> timerSeconds = const Value.absent(),
            Value<int> stopwatchSeconds = const Value.absent(),
            Value<int?> secondsSpent = const Value.absent(),
            Value<int?> autoPauseSeconds = const Value.absent(),
            Value<bool> isDone = const Value.absent(),
            Value<DateTime?> targetDateTime = const Value.absent(),
          }) =>
              TodoItemDBCompanion(
            id: id,
            title: title,
            content: content,
            category: category,
            timerSeconds: timerSeconds,
            stopwatchSeconds: stopwatchSeconds,
            secondsSpent: secondsSpent,
            autoPauseSeconds: autoPauseSeconds,
            isDone: isDone,
            targetDateTime: targetDateTime,
          ),
          createCompanionCallback: ({
            Value<int?> id = const Value.absent(),
            required String title,
            required String content,
            Value<String> category = const Value.absent(),
            Value<int> timerSeconds = const Value.absent(),
            Value<int> stopwatchSeconds = const Value.absent(),
            Value<int?> secondsSpent = const Value.absent(),
            Value<int?> autoPauseSeconds = const Value.absent(),
            Value<bool> isDone = const Value.absent(),
            Value<DateTime?> targetDateTime = const Value.absent(),
          }) =>
              TodoItemDBCompanion.insert(
            id: id,
            title: title,
            content: content,
            category: category,
            timerSeconds: timerSeconds,
            stopwatchSeconds: stopwatchSeconds,
            secondsSpent: secondsSpent,
            autoPauseSeconds: autoPauseSeconds,
            isDone: isDone,
            targetDateTime: targetDateTime,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TodoItemDBTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TodoItemDBTable,
    TodoItemDBData,
    $$TodoItemDBTableFilterComposer,
    $$TodoItemDBTableOrderingComposer,
    $$TodoItemDBTableCreateCompanionBuilder,
    $$TodoItemDBTableUpdateCompanionBuilder,
    (
      TodoItemDBData,
      BaseReferences<_$AppDatabase, $TodoItemDBTable, TodoItemDBData>
    ),
    TodoItemDBData,
    PrefetchHooks Function()>;
typedef $$WorkOnSideTodoItemDBTableCreateCompanionBuilder
    = WorkOnSideTodoItemDBCompanion Function({
  Value<int?> id,
  required String title,
  Value<int?> secondsSpent,
  Value<int?> feelingScore,
  Value<int?> usefulScore,
  Value<DateTime?> targetDateTime,
});
typedef $$WorkOnSideTodoItemDBTableUpdateCompanionBuilder
    = WorkOnSideTodoItemDBCompanion Function({
  Value<int?> id,
  Value<String> title,
  Value<int?> secondsSpent,
  Value<int?> feelingScore,
  Value<int?> usefulScore,
  Value<DateTime?> targetDateTime,
});

class $$WorkOnSideTodoItemDBTableFilterComposer
    extends FilterComposer<_$AppDatabase, $WorkOnSideTodoItemDBTable> {
  $$WorkOnSideTodoItemDBTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get title => $state.composableBuilder(
      column: $state.table.title,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get secondsSpent => $state.composableBuilder(
      column: $state.table.secondsSpent,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get feelingScore => $state.composableBuilder(
      column: $state.table.feelingScore,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get usefulScore => $state.composableBuilder(
      column: $state.table.usefulScore,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get targetDateTime => $state.composableBuilder(
      column: $state.table.targetDateTime,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$WorkOnSideTodoItemDBTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $WorkOnSideTodoItemDBTable> {
  $$WorkOnSideTodoItemDBTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get title => $state.composableBuilder(
      column: $state.table.title,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get secondsSpent => $state.composableBuilder(
      column: $state.table.secondsSpent,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get feelingScore => $state.composableBuilder(
      column: $state.table.feelingScore,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get usefulScore => $state.composableBuilder(
      column: $state.table.usefulScore,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get targetDateTime => $state.composableBuilder(
      column: $state.table.targetDateTime,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

class $$WorkOnSideTodoItemDBTableTableManager extends RootTableManager<
    _$AppDatabase,
    $WorkOnSideTodoItemDBTable,
    WorkOnSideTodoItemDBData,
    $$WorkOnSideTodoItemDBTableFilterComposer,
    $$WorkOnSideTodoItemDBTableOrderingComposer,
    $$WorkOnSideTodoItemDBTableCreateCompanionBuilder,
    $$WorkOnSideTodoItemDBTableUpdateCompanionBuilder,
    (
      WorkOnSideTodoItemDBData,
      BaseReferences<_$AppDatabase, $WorkOnSideTodoItemDBTable,
          WorkOnSideTodoItemDBData>
    ),
    WorkOnSideTodoItemDBData,
    PrefetchHooks Function()> {
  $$WorkOnSideTodoItemDBTableTableManager(
      _$AppDatabase db, $WorkOnSideTodoItemDBTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer: $$WorkOnSideTodoItemDBTableFilterComposer(
              ComposerState(db, table)),
          orderingComposer: $$WorkOnSideTodoItemDBTableOrderingComposer(
              ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int?> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<int?> secondsSpent = const Value.absent(),
            Value<int?> feelingScore = const Value.absent(),
            Value<int?> usefulScore = const Value.absent(),
            Value<DateTime?> targetDateTime = const Value.absent(),
          }) =>
              WorkOnSideTodoItemDBCompanion(
            id: id,
            title: title,
            secondsSpent: secondsSpent,
            feelingScore: feelingScore,
            usefulScore: usefulScore,
            targetDateTime: targetDateTime,
          ),
          createCompanionCallback: ({
            Value<int?> id = const Value.absent(),
            required String title,
            Value<int?> secondsSpent = const Value.absent(),
            Value<int?> feelingScore = const Value.absent(),
            Value<int?> usefulScore = const Value.absent(),
            Value<DateTime?> targetDateTime = const Value.absent(),
          }) =>
              WorkOnSideTodoItemDBCompanion.insert(
            id: id,
            title: title,
            secondsSpent: secondsSpent,
            feelingScore: feelingScore,
            usefulScore: usefulScore,
            targetDateTime: targetDateTime,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$WorkOnSideTodoItemDBTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $WorkOnSideTodoItemDBTable,
        WorkOnSideTodoItemDBData,
        $$WorkOnSideTodoItemDBTableFilterComposer,
        $$WorkOnSideTodoItemDBTableOrderingComposer,
        $$WorkOnSideTodoItemDBTableCreateCompanionBuilder,
        $$WorkOnSideTodoItemDBTableUpdateCompanionBuilder,
        (
          WorkOnSideTodoItemDBData,
          BaseReferences<_$AppDatabase, $WorkOnSideTodoItemDBTable,
              WorkOnSideTodoItemDBData>
        ),
        WorkOnSideTodoItemDBData,
        PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TodoItemDBTableTableManager get todoItemDB =>
      $$TodoItemDBTableTableManager(_db, _db.todoItemDB);
  $$WorkOnSideTodoItemDBTableTableManager get workOnSideTodoItemDB =>
      $$WorkOnSideTodoItemDBTableTableManager(_db, _db.workOnSideTodoItemDB);
}
